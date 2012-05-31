requirejs.config
  shim:
    spine: 
      deps: [],
      exports: 'Spine'

requirejs ['overrides', 'mediator', 'spine', 'cell'],

(overrides, mediator, spine) ->
  console.log
    overrides: overrides
    mediator: mediator
    spine: spine
