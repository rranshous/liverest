

# tracker which associates sockets to their tracked cells

define ['mediator', 'socket_cell_tracker'], (mediator, socket_cell_tracker) ->

  # when the socket cell tracker tracks a new socket
  # setup the other side of the relation here
  socket_cell_tracker.on 'tracker:add', (data) =>
    socket = cell_socket_tracker.first data.id
    # add the cell to the list of tracking cells associated to the socket
    socket.get 'tracking_cells', (err, cells) =>
      cells = cells or []
      cells.push(data.id)
      socket.set 'tracking_cells', cells

  # if the cell's event has both a connection obj and an id
  # than it's good to track
  add_tracking = (event_data) =>
    if event_data.__connection
      socket_cell_tracker.track event_data.id, event_data.__connection

  # we want to sit on all the cell events which would mean a client
  # is interested in the cell. When a client does any of these events
  # we want to start tracking it
  mediator.on 'cell:set_value', add_tracking
  mediator.on 'cell:set_data', add_tracking
  mediator.on 'cell:init', add_tracking

  return
