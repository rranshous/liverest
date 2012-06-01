
requirejs = require('requirejs')

requirejs ['spine', 'socket.io', 'express','mediator', 'cell' ],
(spine, io, express, mediator, cell) ->

  PORT = 8080 # what port to host on
  AUTHORITY = true # are we a cell authority ?

  # Setup our HTTP host
  http_app = express()
  http_server = http_app.listen(PORT)
  http_app.use express.static __dirname + '/' # static hosting

  # now our socket io server, based on http
  io = io.listen http_server

  # when a new client connects we are going to hook it up to the mediator
  io.socket.on 'connection', (socket) ->

    # when an event comes in, it needs to go through the mediator
    socket.on -> true, mediator.fire.curry()
    
    # when the mediator puts off an event, we need to check if
    # has to do with a cell this socket cares about, if so relay
    # the event to the socket
    mediator.on

      # this function checks if the event is one the socket will care about
      (event, data, r) =>

        # check if the data has to do with a cell the socket cares about
        if data.id
          # to figure out if we care check the list of the sockets tracked cells
          socket.get 'tracking_cells', (err, cells) =>
            r(true) if data.id in cells else r(false)

        # we dont care about the event if it has no id
        else
          r(false)

      # this function handles cells from the mediator
      # we've already decided we want them, just pass them on
    , socket.emit.curry()

# and all the socket handlers
io.sockets.on 'connection', (socket) ->

  # handle the client setting values
  socket.on 'set_cell_value', (data) ->
    console.log "set cell value:"
    console.log data
    set_cell_value data.id, data.key, data.value, true,
      (id, key, value, old_value) ->
        console.log "cell value set #{id} #{key} #{value} #{old_value}"
        ###
        # TODO: why doesnt this work ?
        [socket.emit, socket.broadcast.emit].forEach (emitter, i, l) ->
        console.log "emitter #{emitter}"
        ###
        args = 
          success: true,
          id: id,
          key: key,
          value: value,
          token: data?.token
        # fire for all sockets
        # TODO: test io.emit
        socket.emit 'set_cell_value', args
        socket.broadcast.emit 'set_cell_value', args

  # handle the client setting multiple values
  socket.on 'set_cell_data', (data) ->
    console.log "set cell data"
    console.log data
    set_cell_data data.id, data.data, (id, data, old_data) =>
      console.log "cell data set #{id}"
      args = 
        success: true,
        id: id,
        data: data,
        old_data: old_data,
        token: data?.token
      socket.emit 'set_cell_data', args
      socket.broadcast.emit 'set_cell_data', args
