

# responds to init events from an object with
# a set data event for the init'd object

define ['mediator', 'cell_id_tracker'], (mediator, cell_id_tracker) ->

  # if a client init's a cell and it has an id, than we want
  # to send a snapshot of the data to the client as a set.
  # we'll use 0 as the token so that the client can tell it's
  # the current saved state, but that any event it may have
  # received since initing the cell is higher precident
  fire_cell_state = (to_obj, id) =>
    cell = cell_id_tracker.first(id)
    if cell?
      to_obj.fire 'cell:set_data', 
        id: id,
        token: 0,
        data: cell.get_data()
    
  meditor.on 'cell:init', (data) =>
    fire_cell_state data.__connection, id

