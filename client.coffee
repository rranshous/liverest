
# cells = { id: [{}] }
# cell = { id: <>, k:v }
# if _k exists it will hold the token for the event
#  which set the data
cells = {}
last_token_id = 0
next_token_id = ->
    last_token_id += 1
    last_token_id

event_handlers = 

  # handles internal / external event
  set_cell_value: (data) ->

    id = data.id
    key = data.key
    value = data.value
    token = data.token

    set_value = (cell) ->
      # check for an outstanding set
      token_key = '_'+key
      if token_key in cell
        # if this set is older, dont bother updating
        if token < cell[token_key]
          continue
        else
          # update the token to ours
          cell[token_key] = token

      # we're good to set the value
      cell.key = value

    # go through cells w/ matching ids
    for cell in (cells[id] or [])
      set_value(cell)

    # go through the cells which didn't have ids
    # and this was their first set
    for cell in (cells[token] or [])
      set_value(cell)


  # handles internal / external event
  set_cell_data: (data) ->

    id = data.id
    token = id.token
    new_values = data.new_values

    # go through the key / values leaning on other handler
    for k, v of new_values
      handlers.set_cell_value id, 
        id: id,
        key: k,
        value: v,
        token: token


# setup socket
socket = io.connect 'http://localhost'

# register socket handlers which handle updating all
# cell values and local handlers
for event_name, handler of event_handlers
  socket.on event_name, handler
  cells.on event_name, handler

# connect up handlers which push local events server side
cells.on 'set_cell_value', (data) ->
  socket.emit 'set_cell_value', data

cells.on 'set_cell_data', (data) ->
  socket.emit 'set_cell_data', data

class Cell
  constructor: (@id) ->
    @data = {}

  set: (key, value, token, fire = true) ->

    # generate a token for the set
    token = get_next_token()

    # set the new value 
    @data[key] = value

    # and update the key's token
    token_key = '_'+key
    @data[token_key] = token

    # if we don't have an id yet save a ref to ourself
    # in cells token lookup
    unless @id
      (if cells[token_key] then cells[token_key] else =>
        cells[token_key] = []).append(this)

    # let the world know
    cells.fire 'set_cell_value',
      id: @id,
      key: key,
      value: value,
      token: token

  get: (key) ->
    @data[key]

  set_data: (data) ->

    # generate token
    token = get_next_token()

    # update ourself
    @set k, v, token, false for k, v of data

    # let the world know
    cells.fire 'set_cell_data',
      id: @id,
      data: data,
      token: token

  clear: () ->
    @set_data({})
