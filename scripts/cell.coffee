
# global shared cell id counter
_last_cell_id = 0

define ['spine','mediator'], (spine, mediator) ->

  class Cell extends Spine.Module
    @extend Spine.Events

    constructor: (@id) ->
      # store a lookup of when it was set
      @tokens = {}

      # let the world know we're here
      @fire 'cell:init',
        id: @id

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
    clear: ->
      @set_data {}

    # over ride fire so all events go to the mediator
    fire: (args...) ->
      # TODO: figure out if i can do *args
      mediator.fire.apply mediator, args
