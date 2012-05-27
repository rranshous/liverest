
# cells = { id: [{}] }
# cell = { id: <>, k:v }
# if _k exists it will hold the token for the event
#  which set the data
class CellsLookup extends Spine.Module
  @include Spine.Events
  new_token_id: =>
    new Date().getTime()
cells = new CellsLookup()

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
        # if this set is newer, update
        if token > cell[token_key]
          cell[token_key] = token

      # we're good to set the value
      cell.key = value

    # go through cells w/ matching ids
    (cells[id] or []).forEach (cell) =>
      set_value(cell)

    # go through the cells which didn't have ids
    # and this was their first set
    (cells[token] or []).forEach (cell) =>
      # set the value
      set_value(cell)
      # move the cell into the id based lookup
      cells[id] = [] unless cells[id]
      cells[id].append(cell)
      # remove from token based lookup
      cells[token].remove(cell)
      


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
socket = io.connect()

socket.on 'connect', ->

  console.log 'connected!'

  # register socket handlers which handle updating all
  # cell values and local handlers
  for event_name, handler of event_handlers
    socket.on event_name, handler
    cells.bind event_name, handler

  # connect up handlers which push local events server side
  cells.bind 'set_cell_value', (data) ->
    socket.emit 'set_cell_value', data

  cells.bind 'set_cell_data', (data) ->
    socket.emit 'set_cell_data', data


class Cell
  constructor: (@id) ->
    # note our data
    @data = {}

  set: (key, value, token, fire = true) ->

    # generate a token for the set
    token = cells.new_token_id()

    # set the new value 
    @data[key] = value

    # and update the key's token
    token_key = '_'+key
    @data[token_key] = token 

    # if we don't have an id yet save a ref to ourself
    # in cells token lookup
    unless @id
      cells[token_key] = [] unless cells[token_key]
      cells[token_key].push(this)

    # let the world know
    cells.trigger 'set_cell_value',
      id: @id,
      key: key,
      value: value,
      token: token

  get: (key) ->
    @data[key]

  set_data: (data) ->

    # generate token
    token = cells.new_token_id()

    # update ourself
    @set k, v, token, false for k, v of data

    # let the world know
    cells.trigger 'set_cell_data',
      id: @id,
      data: data,
      token: token

  clear: () ->
    @set_data({})


# put our app into the global namespace
app = @app = {}
app.cells = cells
app.Cell = Cell
