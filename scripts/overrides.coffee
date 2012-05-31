
define ->
  # add remove method to array
  Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

  # adding curring to functions
  Function::curry = ->
    func = @
    constructor_args = arrSlice.call arguments
    ->
      func_args = arrSlice.call arguments
      func.apply @, constructor_args.concat(func_args)

  return {}
