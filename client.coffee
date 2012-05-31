# our cells collection
cells = new app.types.Cells()

# setup socket
socket = io.connect()

# when the socket has connected to the backend
# setup listeners for cell data changes
socket.on 'connect', ->

  # hook up our cell's events to the backend
  cells.bind socket.emit.curry 'set_cell_value'
  cells.bind socket.emit.curry 'set_cell_data'

# the same function is going to handle receiving
# set cell events from the front and back end
handle_set_cell_value = (data) ->

  # pull out the info we care about
  id = data.id
  key = data.key
  value = data.value
  token = data.token

  console.log "handler [set_cell_value] #{id} #{key} #{value} #{token}"

  set_value = (cell) ->
    # check for an outstanding set
    token_key = '_'+key
    if token_key in cell
      # if this set is newer, update
      if token > cell[token_key]
        console.log "set_value token new #{cell[token_key]} #{token}"
        cell[token_key] = token
      else
        console.log "set_value token [#{token}] old"
        return

    # we're good to set the value
    console.log "set_value: #{key} #{value}"
    cell.key = value

  # go through cells w/ matching ids
  console.log "going through id cells #{cells[id] or []}"
  cells.for_each id, set_value

  # go through the cells which didn't have ids
  # and this was their first set
  console.log "going through token cells #{cells[token] or []}"
  cells.for_each token, set_value

  # go through all the token cells, moving them from the token
  # lookup to the id, if we have an id
  if id?:
    console.log "cells now has id, updating"
    cells.for_each token, (cell) =>
      # move the cell into the id based lookup
      cells[id] = [] unless cells[id]
      cells[id].push(cell)
      # remove from token based lookup
      cells[token].remove(cell)
      unless cells[token].length
        delete cells[token]


  # handles internal / external event
  set_cell_data: (data) ->

    id = data.id
    token = id.token
    new_values = data.new_values

    console.log "set_cell_data #{id} #{new_value} #{token}"

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
    console.log "cell set_cell_value => server"
    socket.emit 'set_cell_value', data

  cells.bind 'set_cell_data', (data) ->
    console.log "cell set_cell_data => server"
    socket.emit 'set_cell_data', data


# put our app into the global namespace
app = @app = {}
app.cells = cells
