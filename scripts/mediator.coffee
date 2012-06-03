
define ['spine'], (spine) ->

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
  class Mediator extends spine.Module
    @extend Spine.Events

    # take another class and extend it to be magical
    class_extend: (obj) ->

      to_update = 
        '_bind': ['addListener', 'bind', 'on']
        '_trigger': ['fire', 'trigger', 'emit']
        '_unbind': ['un', 'remove_listener', 'unbind']

      for fn, attrs of to_update
        for attr in attrs
          if obj::[attr]
            obj::['__'+attr] = obj::[attr]
            console.log "#{attr} => #{fn}"
            obj::[attr] = @::[attr]

    # sometimes we already have an instantiated event
    # obj we want to extend, this helps us do that
    instance_extend: (obj) ->

      to_update = 
        '_bind': ['addListener', 'bind', 'on']
        '_trigger': ['fire', 'trigger', 'emit']
        '_unbind': ['un', 'remove_listener', 'unbind']

      for fn, attrs of to_update
        for attr in attrs
          if obj[attr]?
            obj['__'+attr] = obj[attr]
            console.log "#{attr} => #{fn}"
            obj[attr] = @[fn].curry(obj['__'+attr])

    # update bind so that instead of an event name
    # we can define a function which calls a callback
    # with bool as to whether it matches
    _bind: (_super, ev, callback) ->

      console.log "binding"
      
      # catch events which are functions
      if typeof ev is 'function'
        console.log "not calling super #{ev}"
        conditions = @_conditions or= []
        condition = new Condition ev, callback
        conditions.push condition
        this
      else
        console.log "calling super #{ev}"
        _super ev, callback

    _trigger: (_super, args...) ->

      # copy the args before we pass them on,
      # super modifies them
      _args = args[..]

      # now we want to go through all the conditions matching them
      @_conditions.forEach (condition) =>
        condition.match _args, (match) =>
          # send the event out to the callback
          if match
            condition.call.apply condition, _args[0], args[1..]

      # let the base class do it's thing
      # TODO: figure out if i can do *args
      _super.apply @, args

    _unbind: (_super, ev, callback) ->

      # remove any matching conditions
      conditions.forEach (condition) ->
        if condition.match_unbind ev, callback
          conditions.remove(condition)

      # respect
      _super ev, callback

    on: (args...) -> @_bind.apply @, args
    fire: (args...) -> @_trigger.apply @, args
    un: (args...) -> @_unbind.apply @, args


  mediator = new Mediator()
