
# global shared cell id counter
_last_cell_id = 0

define ['spine','mediator'], (spine, mediator) ->

  # only pass on to callback data which @ least
  # matches our filter (doesn't have to be exact)
  data_filter = (filter_data, callback) ->
    (data) =>
      for k, v of filter_data
        unless data[k] == v
          return
      callback data

  class Cell extends Spine.Module
    @extend Spine.Events

    constructor: (data) ->

      # grab an id if any
      @id = if typeof data == 'number' then data else data.id

      # store a lookup of when it was set
      @tokens = {}

      # let the world know we're here
      @fire 'cell:init',
        id: @id

      # hook up to the mediator so that any events
      # which come through and update our data update us
      mediator.on 'cell:set_data', @handle_set_data
      mediator.on 'cell:get_data', @handle_get_data

      # if we have sub data (init data) in the data
      # than we're going to set it
      @set_data data.data

    @_new_cell_id: ->
      _last_cell_id += 1

    # token's based on timestamps
    _new_token_id: ->
      '' + Date().getTime() + (@id or '')

    # sets the cell's value
    # if token is set only sets if given token
    # is greater than the stored token
    set: (key, value, token, fire = true, callback= ->) ->

      console.log "cell [set] #{key} #{value} #{token} #{fire}"

      # if token is given and older, we're done
      unless token? or token > @tokens[key]
        # call back w/ success being false
        callback false, key, value
        return

      # generate a new token for this set op
      token = @tokens[key] = @_new_token_id()

      # actually set the data
      @_set key, value, =>

        # let the world know
        if fire
          console.log "cells firing set_cell_value"
          @fire 'cell:set_value',
            key: key,
            value: value,
            token: token

        # call back with much success
        callback true, key, value

    _set: (key, value, callback= ->) ->
      callback true, key, value

    # gets a value from the 
    get: (key) ->
      @data[key]

    # return all the cell's data
    get_data: ->
      @data

    # sets multiple values
    set_data: (data, callback= ->) ->

      # this can't be used for clearning
      unless data?.length
        return

      # generate token
      token = @_new_token_id()

      # keep track of how many set's we've done
      total = data.length
      done = 0

      # update ourself, don't emit
      for k,v of data
        @set k, v, token, false, (success, key, value) =>
          done += 1

          # did we finish ?
          if total == done
            callback true, data

            # let the world know
            @fire 'cell:set_data',
              id: @id,
              data: data,
              token: token

    # clears all the cell's values
    clear: (token, callback= ->) ->
 
      # clear any keys for which
      # the given token is greater
      cleared = {}
      for k, v of @data
        if not token? or @tokens?[k] < v
          cleared[k] = v
          delete @data[k]

      # let the world know
      @fire 'cell:clear',
        token: token

      # let the callback know what
      # we removed
      callback(cleared)


    # handles events we receive about cell updates
    handle_set_value: (data) ->
      # we only pay attention to events which have to do with us
      return unless @id == id
      @set data

    handle_set_data: (data) ->
      return unless @id == id
      @set_data data

    # send all events through the mediator
    fire: mediator.fire

