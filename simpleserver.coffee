# Web server
io = require 'socket.io'
express = require 'express'
app = express()
server = app.listen 8080
# host our statics
#console.info "making static #{__dirname + '/'}"
app.use express.static __dirname + '/'
# socket IO layer
io = io.listen server

# helper method for cell ids
last_cell_id = 0
next_cell_id = ->
  last_cell_id += 1
  last_cell_id

cells = {}

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
      new_value : value
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


# simple methods for accessing cell's data
get_cell_data = (id, callback) ->
  callback id, cells.id or {}
get_cell_value = (id, key, callback) ->
  callback id, cells?.id?.key

# and all the socket handlers
io.sockets.on 'connection', (socket) ->

  # handle the client setting values
  socket.on 'set_cell_value', (data) ->
    set_cell_value data.id, data.key, data.value, (id, key, value, old_value) =>
      socket.emit 'set_cell_value', 
        success: true,
        id: id,
        key: key,
        value: value,
        token: data?.token

  # handle the client setting multiple values
  socket.on 'set_cell_data', (data) ->
    set_cell_data data.id, data.data, (id, data, old_data) =>
      socket.emit 'set_cell_data',
        success: true,
        id: id,
        data: data,
        old_data: old_data,
        token: data?.token

  #client wants a value
  socket.on 'get_cell_value', (data) ->
    get_cell_value data.id, data.key, (id, value) =>
      socket.emit 'get_cell_value',
        success: true,
        id: id,
        key: key,
        value: value,
        token: data?.token

  socket.on 'get_cell_data', (data) ->
    get_cell_data data.id, (id, data) =>
      socket.emit 'get_cell_data',
        success: true,
        id: id,
        data: data,
        token: data?.token
