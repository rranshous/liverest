// Generated by CoffeeScript 1.3.3
(function() {

  define(function() {
    Array.prototype.remove = function(e) {
      var t, _ref;
      if ((t = this.indexOf(e)) > -1) {
        return ([].splice.apply(this, [t, t - t + 1].concat(_ref = [])), _ref);
      }
    };
    Function.prototype.curry = function() {
      var constructor_args, func;
      func = this;
      constructor_args = arrSlice.call(arguments);
      return function() {
        var func_args;
        func_args = arrSlice.call(arguments);
        return func.apply(this, constructor_args.concat(func_args));
      };
    };
    return {};
  });

}).call(this);