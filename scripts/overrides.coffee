
define ->

  slice = Array::slice

  # add remove method to array
  Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

  # adding curring to functions
  Function::curry = ->
    func = @
    constructor_args = slice.call arguments, 0
    ->
      func_args = slice.call arguments, 0
      func.apply @, constructor_args.concat func_args

  return {}
