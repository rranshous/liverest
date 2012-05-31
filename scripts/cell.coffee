
define ['spine'], (spine) ->

  class Cell extends Spine.Module
    @extend Spine.Events

    constructor: (@id) ->
      # note our data
      @data = {}
      # store a lookup of when it was set
      @tokens = {}

    # token's based on timestamps
    _new_token_id: ->
      new Date().getTime()

    # sets the cell's value
    # if token is set only sets if given token
    # is greater than the stored token
    set: (key, value, token, fire = true) ->

      console.log "cell [set] #{key} #{value} #{token} #{fire}"

      # set the new value 
      @data[key] = value

      # if token is given and older, we're done
      return unless token? or token > @tokens[key]

      # generate a new token for this set op
      token = @tokens[key] = @_new_token_id()

      # let the world know
      if fire
        console.log "cells firing set_cell_value"
        @trigger 'set_cell_value',
          key: key,
          value: value,
          token: token

    # gets a value from the 
    get: (key) ->
      @data[key]

    # sets multiple values
    set_data: (data) ->

      # this can't be used for clearning
      unless data?.length
        return

      # generate token
      token = @_new_token_id()

      # update ourself, don't emit
      @set k, v, token, false for k, v of data

      # let the world know
      @trigger 'set_cell_data',
        id: @id,
        data: data,
        token: token

    # clears all the cell's values
    clear: () ->
      @set_data {}
