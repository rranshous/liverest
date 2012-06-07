
define ->

  last_cell_id = 0

  fire_set_value: (to_obj, id, key, value, token) ->
    to_obj.fire 'cell:set_value',
      id: id,
      key: key,
      value: value,
      token: token

  fire_set_data: (to_obj, id, data, token) ->
    # let the world know
    to_obj.fire 'cell:set_data',
      id: id,
      data: data,
      token: token

  new_cell_id: ->
    last_cell_id += 1

  # token's based on timestamps
  new_token_id: ->
    '' + (new Date().getTime()) + (@id or '')
