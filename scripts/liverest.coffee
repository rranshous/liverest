

define ['socketio_handler'], (socketio_handler) ->
  
  # add a new socketio server to handle the events for
  add_socketio_server: socketio_handler.handle_server,

  # add a new socketio socket to handle events for
  add_socketio_socket: socketio_handler.handle_socket

