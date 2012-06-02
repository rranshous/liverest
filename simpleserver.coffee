
requirejs = require('requirejs')

requirejs [
  'spine', 
  'socket.io', 'express',
  'mediator', 'cell', 'socketio_handler'
],

(spine,
 io, express,
 mediator, Cell, socketio_handler) ->

  PORT = 8080 # what port to host on
  AUTHORITY = true # are we a cell authority ?

  # Setup our HTTP host
  http_app = express()
  http_server = http_app.listen(PORT)
  http_app.use express.static __dirname + '/' # static hosting

  # now our socket io server, based on http
  io = io.listen http_server

  # add the socket io server to the socket handler
  # the handler makes sure the events coming in on the sockets
  # get pushed through mediator, also mediator events
  # which pertain to connected sockets get pushed out
  socketio_handler io
