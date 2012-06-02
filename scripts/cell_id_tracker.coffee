
# tracker which associates cell ids to cell instances
#
define ['mediator', 'tracker'], (mediator, tracker) ->

  # tracker for associating cell's w/ their id
  cells_id_tracker = new Tracker()

  # if an init event comes though, set up a new cell
  setup_cell = (data) =>
    # if we already have a cell for this id or the
    # cell doesn't have an ID, not worth tracking
    unless cell_id_tracker.first(data.id) or not data.id?
      cell = new Cell data
      cells_id_tracker.track cell.id, cell

  # we subscribe to all of these events b/c we can't
  # be sure at what point an id will be assigned
  mediator.on 'cell:init', setup_cell
  mediator.on 'cell:set_value', setup_cell
  mediator.on 'cell:set_data', setup_cell

  cells_id_tracker
