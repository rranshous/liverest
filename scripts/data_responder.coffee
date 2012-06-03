

# responds to init events from an object with
# a set data event for the init'd object

define ['mediator', 'cell_id_tracker'], (mediator, cell_id_tracker) ->

  # if a client init's a cell and it has an id, than we want
  # to send a snapshot of the data to the client as a bunch of value sets
  # sending the set's token along so that the client can figure out what
  # to keep
  fire_cell_state = (to_obj, id) =>
    cell = cell_id_tracker.first(id)
    if cell?
      for k, v of cell.get_data()
        cell.fire_set_data to_obj, id, key, value, cell.tokens[k]
    
  meditor.on 'cell:init', (data) =>
    fire_cell_state data.__connection, id

