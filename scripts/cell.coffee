
define ['spine'], (spine) ->

  class Cell extends Spine.Module
    @extend Spine.Events

    constructor: (@id) ->
      # store a lookup of when it was set
      @tokens = {}

    # token's based on timestamps
    _new_token_id: ->
      new Date().getTime()

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
      @_set key, value, ->

        # let the world know
        if fire
          console.log "cells firing set_cell_value"
          @fire 'set_cell_value',
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
      @set k, v, token, false, (success, key, value) ->
        done += 1

        # did we finish ?
        if total == done
          callback true, data

          # let the world know
          @fire 'set_cell_data',
            id: @id,
            data: data,
            token: token

    # clears all the cell's values
    clear: () ->
      @set_data {}
