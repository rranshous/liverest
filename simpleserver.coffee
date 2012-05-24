## STATIC SERVER
file = new require('node-static').Server './public'
require('http').createServer req, resp ->
  req.addListener 'end', ->
    file.serve(req, resp)

# our lookup of cell data
cells = {}

last_cell_id = 0
next_cell_id = ->
  last_cell_id += 1
  last_cell_id

# set single cell value
# callback: id, key, value, old_value
set_cell_value = (id, key, value, emit = true, callback) ->
  # get the cell an id, if it didn't bring it's own
  id = next_cell_id() if not id
  # setup some space for the cell if it's new
  cell = if cells[id]? then cells[id] else ->
    cells[id] = {}
    cells[id]
  old_value = cell[key]
  cell[key] = value
  # fire event if requested
  if emit
    cells.emit 'set_cell_value',
      id : id,
      key : key,
      old_value : old_value,
      new_value : new_value
  callback id, key, value, old_value

# set multiple values for a cell
# callback: id, data, old_data
set_cell_data = (id, data, callback) ->
  count = 0
  len = data.length
  old_values = {}
  for key, value of data
    # set value, don't fire event
    set_cell_value key, value, false, (_id, key, value, old_value) =>
      id = _id if not id
      count += 1
      old_values[key] = old_value
      if count is len
        cells.emit 'set_cell_data',
          id: id,
          old_values: old_values,
          new_values: data
  # if they pass us something empty, it means blank it out
  cells[id] = {} if data.length == 0
  callback id, data


get_cell_data = (id, callback) ->
  callback id, cells.id or {}

get_cell_value = (id, key, callback) ->
  callback id, cells?.id?.key

io = require('socket.io').listen 8080
io.sockets.on 'connection', (socket) ->
  
  socket.on 'set_cell_value', (data) ->
    set_cell_value data.id, data.key, data.value, (id, key, value, old_value) =>
      socket.emit 'set_cell_value', 
        success: true,
        id: id,
        key: key,
        value: value,
        token: data?.token

  socket.on 'set_cell_data', (data) ->
    set_cell_data data.id, data.data, (id, data, old_data) =>
      socket.emit 'set_cell_data',
        success: true,
        id: id,
        data: data,
        old_data: old_data,
        token: data?.token

  socket.on 'get_cell_value', (data) ->
    get_cell_value data.id, data.key, (id, value) =>
      socket.emit 'get_cell_value',
        success: true,
        id: id,
        key: key,
        value: value,
        token: data?.token

  socket.on 'set_cell_data', (data) ->
    get_cell_data data.id, (id, data) =>
      socket.emit 'get_cell_data',
        success: true,
        id: id,
        data: data,
        token: data?.token
