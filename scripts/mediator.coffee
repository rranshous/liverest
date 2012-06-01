
define ['spine'], (spine) ->

  class Condition
      constructor: (@fn, @callback) ->

      match: (ev, data.., callback) ->
        @fn ev, data, callback

      call: (args..) ->
        @callback args

      match_unbind: (fn, callback) ->
        return true if @fn is fn and @callback is callback
        return false

  # Mediator
  # TODO: splay over rides into seperate extendable class
  class Mediator extends spine.Module
    @extend Spine.Events

    # update bind so that instead of an event name
    # we can define a function which calls a callback
    # with bool as to whether it matches
    bind: (ev, callback) ->
      
      # catch events which are functions
      if typeof ev is 'function'
        conditions = @_conditions or= []
        condition = new Condition ev, callback
        conditions.push condition
        this
      else
        super ev, callback

    trigger: (args...) ->

      # copy the args before we pass them on,
      # super modifies them
      _args = args[..]

      # now we want to go through all the conditions matching them
      for condition in @_conditions
        if condition.match _args, (match) =>
          # send the event out to the callback
          condition.call.apply condition, _args[0], args[1..] if match

      # let the base class do it's thing
      # TODO: figure out if i can do *args
      super.apply super, args

    unbind: (ev, callback) ->

      # remove any matching conditions
      conditions.forEach (condition) ->
        if condition.match_unbind ev, callback
          conditions.remove(condition)
        delete condition

      # respect
      super ev, callback

    # convenience mapping
    on: @bind
    un: @unbind
    fire: @trigger
    first: @one

  mediator = new Mediator()
