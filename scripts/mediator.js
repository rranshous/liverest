// Generated by CoffeeScript 1.3.3
(function() {
  var __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['spine'], function(spine) {
    var Condition, Mediator, mediator;
    Condition = (function() {

      function Condition(fn, callback) {
        this.fn = fn;
        this.callback = callback;
      }

      Condition.prototype.match = function() {
        var callback, data, ev, _i;
        ev = arguments[0], data = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
        return this.fn(ev, data, callback);
      };

      Condition.prototype.call = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.callback.apply(this.callback, args);
      };

      Condition.prototype.match_unbind = function(fn, callback) {
        if (this.fn === fn && this.callback === callback) {
          return true;
        }
        return false;
      };

      return Condition;

    })();
    Mediator = (function(_super) {

      __extends(Mediator, _super);

      function Mediator() {
        return Mediator.__super__.constructor.apply(this, arguments);
      }

      Mediator.extend(Spine.Events);

      Mediator.prototype.class_extend = function(obj) {
        var attr, attrs, fn, to_update, _results;
        to_update = {
          '_bind': ['addListener', 'bind', 'on'],
          '_trigger': ['fire', 'trigger', 'emit'],
          '_unbind': ['un', 'remove_listener', 'unbind']
        };
        _results = [];
        for (fn in to_update) {
          attrs = to_update[fn];
          _results.push((function() {
            var _i, _len, _results1;
            _results1 = [];
            for (_i = 0, _len = attrs.length; _i < _len; _i++) {
              attr = attrs[_i];
              if (obj.prototype[attr]) {
                obj.prototype['__' + attr] = obj.prototype[attr];
                _results1.push(obj.prototype[attr] = this.prototype[attr]);
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      Mediator.prototype.instance_extend = function(obj) {
        var attr, attrs, fn, to_update, _results;
        to_update = {
          '_bind': ['addListener', 'bind', 'on'],
          '_trigger': ['fire', 'trigger', 'emit'],
          '_unbind': ['un', 'remove_listener', 'unbind']
        };
        _results = [];
        for (fn in to_update) {
          attrs = to_update[fn];
          _results.push((function() {
            var _i, _len, _results1;
            _results1 = [];
            for (_i = 0, _len = attrs.length; _i < _len; _i++) {
              attr = attrs[_i];
              if (obj[attr] != null) {
                obj['__' + attr] = obj[attr];
                _results1.push(obj[attr] = this[fn].curry(obj['__' + attr]));
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      Mediator.prototype._bind = function(_super, ev, callback) {
        var condition, conditions;
        if (typeof ev === 'function') {
          conditions = this._conditions || (this._conditions = []);
          condition = new Condition(ev, callback);
          conditions.push(condition);
          return this;
        } else {
          return _super(ev, callback);
        }
      };

      Mediator.prototype._trigger = function() {
        var args, _args, _super,
          _this = this;
        _super = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        _args = args.slice(0);
        this._conditions.forEach(function(condition) {
          return condition.match(_args, function(match) {
            if (match) {
              return condition.call.apply(condition, _args[0], args.slice(1));
            }
          });
        });
        return _super.apply(this, args);
      };

      Mediator.prototype._unbind = function(_super, ev, callback) {
        conditions.forEach(function(condition) {
          if (condition.match_unbind(ev, callback)) {
            return conditions.remove(condition);
          }
        });
        return _super(ev, callback);
      };

      Mediator.prototype.on = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        console.log(this);
        return this._bind.apply(this, args);
      };

      Mediator.prototype.fire = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        console.log(this);
        return this._trigger.apply(this, args);
      };

      Mediator.prototype.un = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        console.log(this);
        return this._unbind.apply(this, args);
      };

      return Mediator;

    })(spine.Module);
    mediator = new Mediator();
    mediator.Mediator = Mediator;
    return mediator;
  });

}).call(this);
