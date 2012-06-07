
# global shared cell id counter
_last_cell_id = 0

define ['spine','mediator','cell_helpers'], (spine, mediator, helpers) ->

  class Cell extends mediator.Eventable

    constructor: (data) ->

      # grab an id if any
      @id = if typeof data == 'number' then data else data?.id

      # store a lookup of when it was set
      @tokens = {}

      # let the world know we're here
      mediator.fire 'cell:init',
        id: @id

      # hook up to the mediator so that any events
      # which come through and update our data update us
      mediator.on 'cell:set_data', @handle_set_data
      mediator.on 'cell:get_data', @handle_get_data

      # hook up with the mediator to see other
      # cell's init's, that way we can send
      # them snapshots of our data if they don't
      # already have it

      # if we have sub data (init data) in the data
      # than we're going to set it
      @set_data data.data if data?.data

    # sets the cell's value
    # if token is set only sets if given token
    # is greater than the stored token
    set: (key, value, token, fire = true, callback= ->) ->

      console.log "cell [set] #{key} #{value} #{token} #{fire}"

      # if token is given and older, we're done
      if token and @tokens[key] and token < @tokens[key]
        console.log "returning based on token"
        # call back w/ success being false
        callback false, key, value
        return

      # generate a new token for this set op
      token = @tokens[key] = helpers.new_token_id()

      # actually set the data
      @_set key, value, =>

        # let the world know
        if fire
          helpers.fire_set_value mediator, @id, key, value, token

        # call back with much success
        callback true, key, value

    _set: (key, value, callback= ->) ->
      callback true, key, value

    # gets a value from the 
    get: (key, callback= ->) ->
      callback @data[key]

    # return all the cell's data
    get_data: (callback) ->
      callback @data

    # sets multiple values
    set_data: (data, token, callback= ->) ->

      # this can't be used for clearning
      unless data?.length
        return

      # generate token
      token = helpers.new_token_id() unless token?

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
          helpers.fire_set_data mediator, @id, data, token

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
      mediator.fire 'cell:clear',
        token: token

      # let the callback know what
      # we removed
      callback(cleared)

    ## event handlers

    # handles events we receive about cell updates
    handle_set_value: (data) ->
      # we only pay attention to events which have to do with us
      return unless @id == data.id
      @set data

    handle_set_data: (data) ->
      return unless @id == data.id
      @set_data data.data, data.token

    # handles other cell's init events
    # the init event comes w/ the new cell's
    # data, we need to respond with set value
    # events for each key / value that we have
    # with a newer token
    handle_init: (data) ->
      return unless @id == data.id

      # if the event has a source obj lets respond
      # to that directly. It will propogate any new data
      # to other clients it's connected to via it's sets
      resp_obj = data.__source or mediator

      # go through the data the cell is aware of
      for k, v of data.data
        # try and set each for our self. anything
        # we can successfully set they had a newer
        # value. anything we can not we need to tell
        # them about
        @set k, v, data.token, true, (success, key, value, token) =>
          unless success
            # fire a responding set value with our value for the 
            # key and it's token
            @get key, (my_value) =>
              helpers.fire_set_data resp_obj, data.id, 
                                    key, my_value, @tokens[key]

