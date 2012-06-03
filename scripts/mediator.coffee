
define ['spine'], (spine) ->

  has_super = (f_name) ->
    if @::__super__?[f_name] then true else false

  class Condition
    constructor: (@fn, @callback) ->

    match: (ev, data..., callback) ->
      @fn ev, data, callback

    call: (args...) ->
      @callback.apply @callback, args

    match_unbind: (fn, callback) ->
      return true if @fn is fn and @callback is callback
      return false


  # Mediator
  class Eventable extends spine.Module

    @include spine.Events

    # take another class and extend it to be magical
    @class_extend: (obj) ->

      to_update = 
        '_bind': ['addListener', 'bind', 'on']
        '_trigger': ['fire', 'trigger', 'emit']
        '_unbind': ['un', 'remove_listener', 'unbind']

      for fn, attrs of to_update
        for attr in attrs
          if obj::[attr]
            obj::['__'+attr] = obj::[attr]
            obj::[attr] = @::[attr]

    # sometimes we already have an instantiated event
    # obj we want to extend, this helps us do that
    @instance_extend: (obj) ->

      to_update = 
        '_bind': ['addListener', 'bind', 'on']
        '_trigger': ['fire', 'trigger', 'emit']
        '_unbind': ['un', 'remove_listener', 'unbind']

      for fn, attrs of to_update
        for attr in attrs
          if obj[attr]?
            obj['__'+attr] = obj[attr]
            obj[attr] = @::[fn].curry(obj['__'+attr])

    # update bind so that instead of an event name
    # we can define a function which calls a callback
    # with bool as to whether it matches
    _bind: (_super, ev, callback) ->

      # if we didn't get passed a super, lets
      # use the default method
      _super = @bind unless _super

      # catch events which are functions
      if typeof ev is 'function'
        conditions = @_conditions or= []
        condition = new Condition ev, callback
        conditions.push condition
        this
      else
        _super ev, callback

    _trigger: (_super, args...) ->

      console.log this
      console.log "trigger: #{args[0]} => #{args[1..]}"
      console.log args

      # if we didn't get passed a super, lets
      # use the default method
      _super = @trigger unless _super

      # copy the args before we pass them on,
      # super modifies them
      _args = args[..]

      # now we want to go through all the conditions matching them
      (@_conditions or []).forEach (condition) =>
        handle_match = (match) =>
          console.log 
            match:match
          condition.call _args... if match
        match_args = _args.concat(handle_match)
        condition.match match_args...

      # let the base class do it's thing
      _super args...

    _unbind: (_super, ev, callback) ->

      # if we didn't get passed a super, lets
      # use the default method
      _super = @unbind unless _super

      # remove any matching conditions
      (@_conditions or []).forEach (condition) ->
        if condition.match_unbind ev, callback
          conditions.remove(condition)

      # respect
      _super ev, callback

    on: (args...) ->
      @_bind undefined, args...
    fire: (args...) -> 
      @_trigger undefined, args...
    un: (args...) ->
      @_unbind undefined, args...

  mediator = new Eventable()
  mediator.Eventable = Eventable
  mediator.is_mediator = true
  return mediator
