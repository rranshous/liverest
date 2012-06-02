

define ['socketio_handler'] ->
  
  # add a new socketio 
  add_socketio_connection: (socketio_connection) =>
    socketio_handler socketio_connection
