requirejs.config
  shim:
    spine: 
      deps: [],
      exports: 'Spine'

requirejs ['overrides', 'mediator', 'spine', 'cell'],

(overrides, mediator, spine, cell) ->

  # put into global for debuging
  @app = 
    overrides: overrides
    mediator: mediator
    spine: spine
    cell: cell
