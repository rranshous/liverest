
requirejs = require('requirejs')

requirejs ['spine', 'socket.io', 'express','mediator', 'mediator_shim', 'cell' ],
(spine, io, express, mediator, mediator_shim, cell) ->

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

    # update the socket so that it has better (internal) event support
    mediator_shim.instance_extend socket

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
