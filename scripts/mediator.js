// Generated by CoffeeScript 1.3.3
(function() {
  var __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['spine'], function(spine) {
    var Condition, Eventable, has_super, mediator;
    has_super = function(f_name) {
      var _ref;
      if ((_ref = this.prototype.__super__) != null ? _ref[f_name] : void 0) {
        return true;
      } else {
        return false;
      }
    };
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
    Eventable = (function(_super) {

      __extends(Eventable, _super);

      function Eventable() {
        return Eventable.__super__.constructor.apply(this, arguments);
      }

      Eventable.include(spine.Events);

      Eventable.class_extend = function(obj) {
        var attr, attrs, fn, to_update, _i, _len;
        to_update = {
          '_bind': ['addListener', 'bind', 'on'],
          '_trigger': ['fire', 'trigger', 'emit'],
          '_unbind': ['un', 'remove_listener', 'unbind']
        };
        for (fn in to_update) {
          attrs = to_update[fn];
          for (_i = 0, _len = attrs.length; _i < _len; _i++) {
            attr = attrs[_i];
            if (obj.prototype[attr]) {
              obj.prototype['__' + attr] = obj.prototype[attr];
              obj.prototype[attr] = this.prototype[attr];
            }
          }
        }
        return spine.Module.include.call(obj, new Eventable());
      };

      Eventable.instance_extend = function(obj) {
        var attr, attrs, fn, key, reassigned, to_update, value, _ref, _results;
        to_update = {
          '_bind': ['addListener', 'bind', 'on'],
          '_trigger': ['fire', 'trigger', 'emit'],
          '_unbind': ['un', 'remove_listener', 'unbind']
        };
        reassigned = [];
        _ref = new Eventable();
        for (key in _ref) {
          value = _ref[key];
          if (key !== 'included' && key !== 'extended') {
            if (!(__indexOf.call(reassigned, key) >= 0 || (obj[key] != null))) {
              console.log("=> " + key);
              obj[key] = value;
            }
          }
        }
        console.log("reassigned " + reassigned);
        _results = [];
        for (fn in to_update) {
          attrs = to_update[fn];
          _results.push((function() {
            var _i, _len, _results1;
            _results1 = [];
            for (_i = 0, _len = attrs.length; _i < _len; _i++) {
              attr = attrs[_i];
              if (obj[attr] && !(obj[fn] != null)) {
                obj['__' + attr] = obj[attr];
                obj[attr] = obj[fn].curry(obj['__' + attr]);
                console.log("" + attr + " => " + fn);
                reassigned.push(attr);
                _results1.push(reassigned.push('__' + attr));
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          })());
        }
        return _results;
      };

      Eventable.prototype._bind = function(_super, ev, callback) {
        var condition, conditions;
        if (!_super) {
          _super = this.bind;
        }
        if (typeof ev === 'function') {
          conditions = this._conditions || (this._conditions = []);
          condition = new Condition(ev, callback);
          conditions.push(condition);
          return this;
        } else {
          return _super(ev, callback);
        }
      };

      Eventable.prototype._trigger = function() {
        var args, _args, _super,
          _this = this;
        _super = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        console.log(this);
        console.log("trigger: " + args[0] + " => " + args.slice(1));
        console.log(_super);
        if (!_super) {
          _super = this.trigger;
        }
        _args = args.slice(0);
        (this._conditions || []).forEach(function(condition) {
          var handle_match, match_args;
          handle_match = function(match) {
            console.log({
              match: match
            });
            if (match) {
              return condition.call.apply(condition, _args);
            }
          };
          match_args = _args.concat(handle_match);
          console.log({
            match_args: match_args
          });
          return condition.match.apply(condition, match_args);
        });
        console.log({
          trigger_super: _super
        });
        return _super.apply(null, args);
      };

      Eventable.prototype._unbind = function(_super, ev, callback) {
        if (!_super) {
          _super = this.unbind;
        }
        (this._conditions || []).forEach(function(condition) {
          if (condition.match_unbind(ev, callback)) {
            return conditions.remove(condition);
          }
        });
        return _super(ev, callback);
      };

      Eventable.prototype.on = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this._bind.apply(this, [void 0].concat(__slice.call(args)));
      };

      Eventable.prototype.fire = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        console.log("fire");
        return this._trigger.apply(this, [void 0].concat(__slice.call(args)));
      };

      Eventable.prototype.un = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this._unbind.apply(this, [void 0].concat(__slice.call(args)));
      };

      return Eventable;

    })(spine.Module);
    mediator = new Eventable();
    mediator.Eventable = Eventable;
    mediator.is_mediator = true;
    return mediator;
  });

}).call(this);
