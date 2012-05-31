
define ['spine'], (spine) ->

  class Mediator extends spine.Module
    @extend Spine.Events

    constructor: ->

    on: @bind
    un: @unbind
    fire: @trigger
    first: @one

  mediator = new Mediator()
