
define ->

  optional_chain = (functions..) ->
    for fn in functions
      if fn?
        return fn

  chain = (local_fn_name, possible_fns..) ->
    parent = @
    ->
      # when we are called, we want to find the first
      # possible function we can actually run, and run it
      # in the scope that we are running in. we want to pass
      # to the function a reference to the parent's function
      # scoped to our current instance's scope
 
      # we just got called. our current scope is the instance's
      
      # get the first usable function from the parent's prototype
      parent_fn = optional_chain.apply @, possible_fns

      # setup the args to the instance's function. first arg
      # should be the parent's function scoped to instance's scope
      # ala super
      args = [ -> parent_fn.apply @, arguments ]
      # the rest of the args are w/e we received
      args = args.concat arguments

      # now call the defined local function on our instance
      # in our instance's scope, with the args
      @[local_fn_name].apply @, args

  class Condition
    constructor: (@fn, @callback) ->

    match: (ev, data.., callback) ->
      @fn ev, data, callback

    call: (args..) ->
      @callback args

    match_unbind: (fn, callback) ->
      return true if @fn is fn and @callback is callback
      return false

  # something to extend a mediator from 
  class MediatorShim

    # sometimes we already have an instantiated event
    # obj we want to extend, this helps us do that
    @instance_extend: (obj):
      to_update = 
        @_bind: ['addListener', 'bind', 'on']
        @_trigger: ['fire', 'trigger', 'emit']
        @_unbind: ['un', 'remove_listener', 'unbind']

      for fn, attrs in to_update
        for attr in ['addListener', 'bind', 'on']
          if obj[attr]?
            obj['__'+attr] = obj[attr]
            obj[attr] = @_bind.curry(obj['__'+attr])

    # update bind so that instead of an event name
    # we can define a function which calls a callback
    # with bool as to whether it matches
    _bind: (_super, ev, callback) ->
      
      # catch events which are functions
      if typeof ev is 'function'
        conditions = @_conditions or= []
        condition = new Condition ev, callback
        conditions.push condition
        this
      else
        _super ev, callback

    _trigger: (_super, args...) ->

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
      _super.apply super, args

    _unbind: (_super, ev, callback) ->

      # remove any matching conditions
      conditions.forEach (condition) ->
        if condition.match_unbind ev, callback
          conditions.remove(condition)
        delete condition

      # respect
      _super ev, callback

    # we are going to map all these functions down
    # to a single function, this way whatever type of
    # evented object we extend will still work
    
    @on: chain.apply @, '_on', @addListener, @bind, @on
    @addListener: chain.apply @, '_on', @addListener, @bind, @on
    @bind: chain.apply @, '_on', @addListener, @bind, @on

    @fire: chain.apply @, '_fire', @trigger, @emit, @fire
    @trigger: chain.apply @, '_fire', @trigger, @emit, @fire
    @emit: chain.apply @, '_fire', @trigger, @emit, @fire

    @un: chain.apply @, '_unbind', @un, @removeListener, @unbind
    @removeListener: chain.apply @, '_unbind', @un, @removeListener, @unbind
    @unbind: chain.apply @, '_unbind', @un, @removeListener, @unbind
