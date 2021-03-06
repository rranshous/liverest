// Generated by CoffeeScript 1.3.3
(function() {
  var _last_cell_id,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _last_cell_id = 0;

  define(['spine', 'mediator', 'cell_helpers'], function(spine, mediator, helpers) {
    var Cell;
    return Cell = (function(_super) {

      __extends(Cell, _super);

      function Cell(data) {
        this.id = typeof data === 'number' ? data : data != null ? data.id : void 0;
        this.tokens = {};
        mediator.fire('cell:init', {
          id: this.id
        });
        mediator.on('cell:set_data', this.handle_set_data);
        mediator.on('cell:get_data', this.handle_get_data);
        if (data != null ? data.data : void 0) {
          this.set_data(data.data);
        }
      }

      Cell.prototype.set = function(key, value, token, fire, callback) {
        var _this = this;
        if (fire == null) {
          fire = true;
        }
        if (callback == null) {
          callback = function() {};
        }
        console.log("cell [set] " + key + " " + value + " " + token + " " + fire);
        if (token && this.tokens[key] && token < this.tokens[key]) {
          console.log("returning based on token");
          callback(false, key, value);
          return;
        }
        token = this.tokens[key] = helpers.new_token_id();
        return this._set(key, value, function() {
          if (fire) {
            helpers.fire_set_value(mediator, _this.id, key, value, token);
          }
          return callback(true, key, value);
        });
      };

      Cell.prototype._set = function(key, value, callback) {
        if (callback == null) {
          callback = function() {};
        }
        return callback(true, key, value);
      };

      Cell.prototype.get = function(key, callback) {
        if (callback == null) {
          callback = function() {};
        }
        return callback(this.data[key]);
      };

      Cell.prototype.get_data = function(callback) {
        return callback(this.data);
      };

      Cell.prototype.set_data = function(data, token, callback) {
        var done, k, total, v, _results,
          _this = this;
        if (callback == null) {
          callback = function() {};
        }
        if (!(data != null ? data.length : void 0)) {
          return;
        }
        if (token == null) {
          token = helpers.new_token_id();
        }
        total = data.length;
        done = 0;
        _results = [];
        for (k in data) {
          v = data[k];
          _results.push(this.set(k, v, token, false, function(success, key, value) {
            done += 1;
            if (total === done) {
              callback(true, data);
            }
            return helpers.fire_set_data(mediator, _this.id, data, token);
          }));
        }
        return _results;
      };

      Cell.prototype.clear = function(token, callback) {
        var cleared, k, v, _ref, _ref1;
        if (callback == null) {
          callback = function() {};
        }
        cleared = {};
        _ref = this.data;
        for (k in _ref) {
          v = _ref[k];
          if (!(token != null) || ((_ref1 = this.tokens) != null ? _ref1[k] : void 0) < v) {
            cleared[k] = v;
            delete this.data[k];
          }
        }
        mediator.fire('cell:clear', {
          token: token
        });
        return callback(cleared);
      };

      Cell.prototype.handle_set_value = function(data) {
        if (this.id !== data.id) {
          return;
        }
        return this.set(data);
      };

      Cell.prototype.handle_set_data = function(data) {
        if (this.id !== data.id) {
          return;
        }
        return this.set_data(data.data, data.token);
      };

      Cell.prototype.handle_init = function(data) {
        var k, resp_obj, v, _ref, _results,
          _this = this;
        if (this.id !== data.id) {
          return;
        }
        resp_obj = data.__source || mediator;
        _ref = data.data;
        _results = [];
        for (k in _ref) {
          v = _ref[k];
          _results.push(this.set(k, v, data.token, true, function(success, key, value, token) {
            if (!success) {
              return _this.get(key, function(my_value) {
                return helpers.fire_set_data(resp_obj, data.id, key, my_value, _this.tokens[key]);
              });
            }
          }));
        }
        return _results;
      };

      return Cell;

    })(mediator.Eventable);
  });

}).call(this);
