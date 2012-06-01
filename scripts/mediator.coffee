
define ['mediator_shim', 'spine'], (mediator_shim, spine) ->


  # Mediator
  # TODO: splay over rides into seperate extendable class
  class Mediator extends spine.Module
    @extend Spine.Events, mediator_shim

  mediator = new Mediator()
