
requirejs.config
  shim:
    spine: 
      exports: 'Spine'
    "socket.io":
      exports: 'io'
  paths:
    "socket.io": '/socket.io/socket.io.js'

# nothing to see here
requirejs ['overrides', 'socket.io', 'liverest', 'cell'],
  
(overries, io, liverest, Cell) ->

  # and we should be done
  @app = 
    io: io,
    liverest: liverest,
    cell: Cell

  # setup a connection to the server
  socket = io.connect 'http://localhost'

  # pass our socket over to the live rest system
  liverest.add_socketio_socket socket

