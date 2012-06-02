
# something needs to keep track of what clients care about what cells
# a client can be considered to care about a cell if they have set
# the cell's value or initialized a cell

def ['mediator'], (mediator) ->

  # the mediator is going to be putting off events on behalf of cells
  # we care about init and set events
  
  class Tracker

    constructor: ->

      # id => [tracked_items]
      @tracked = {}

    track: (id, obj) ->

      # dont want to track nothing
      return unless id?

      # add something to be tracked
      @tracked[id] = [] unless id in @tracked
      @tracked[id].push(obj) unless obj in @tracked[id]
      return @

    forEach: (id, callback) ->

      # just loop over the tracked objs w/ that id
      (@tracked[id] or []).forEach callback
      return @

    first: (id, callback) ->

      callback if @tracked[id]?.length > 0 then @tracked[id][0]

    remove: (id, obj) ->

      # make sure it's something
      return unless obj? and id?

      # remove a tracked item by id
      @tracked[id]?.remove(obj)
      @