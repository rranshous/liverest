
define ['cell'], (Cell) ->

  class MemoryCell extends Cell

    constructor: () ->
      # store our cell's values
      @data = {}
      super arguments

    _set: (key, value, callback= ->) ->
      @data[key] = value
      callback true, key, value
