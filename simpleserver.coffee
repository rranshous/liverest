
requirejs = require('requirejs')

requirejs [
  'spine', 
  'socket.io', 'express',
  'mediator', 'cell', 'tracker'
],

(spine,
 io, express,
 mediator, Cell, Tracker) ->

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
    mediator.instance_extend socket

    # when an event comes in, it needs to go through the mediator
    socket.on (e,d,r) -> r(true), mediator.fire
    
    # when the mediator puts off an event, we need to check if
    # has to do with a cell this socket cares about, if so relay
    # the event to the socket
    mediator.on \

      # this function checks if the event is one the socket will care about
      (event, data, r) =>

        # check if the data has to do with a cell the socket cares about
        if data.id
          # to figure out if we care check the list of the sockets tracked cells
          socket.get 'tracking_cells', (err, cells) =>
            r(true) if data.id in (cells or []) else r(false)

        # we dont care about the event if it has no id
        else
          r(false)

      # this function handles cells from the mediator
      # we've already decided we want them, just pass them on
    , (event, event_data) =>

      # refire the event through the mediator w/ the socket in the data
      event_data.__connection = socket
      socket.fire event, event_data


  # setup our tracker to associate cell's with sockets
  # which care about them
  socket_cell_tracker = new Tracker()

  # if the cell's event has both a connection obj and an id
  # than it's good to track
  add_tracking = (event_data) =>
    if event_data.__connection and event_data.id
      socket_cell_tracker.track event_data.id, event_data.__connection

  # we want to sit on all the cell events which would mean a client
  # is interested in the cell. When a client does any of these events
  # we want to start tracking it
  mediator.on 'cell:set_value', add_tracking
  mediator.on 'cell:set_data', add_tracking
  mediator.on 'cell:init', add_tracking

  
  # if a client init's a cell and it has an id, than we want
  # to send a snapshot of the data to the client as a set.
  # we'll use 0 as the token so that the client can tell it's
  # the current saved state, but that any event it may have
  # received since initing the cell is higher precident
  broadcast_cell_state = (to_obj, id) =>
    get_cell id, (cell) =>
      if cell
        to_obj.fire 'cell:set_data', 
          id: id,
          token: 0,
          data: cell.get_data()
    
  meditor.on 'cell:init', (data) =>
    broadcast_cell_state socket, id


  # if an init event comes though, set up a new cell
  meditor.on 'cell:init', (data) =>
    setup_cell data
