

# tracker which adds associates cell ids to sockets which
# care about those cells

# TODO: make more generic, they just happen to be sockets they
#       can be anything

define ['mediator','tracker'], (mediator, tracker) ->

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

  socket_cell_tracker
