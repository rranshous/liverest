// Generated by CoffeeScript 1.3.3
(function() {
  var _last_cell_id,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _last_cell_id = 0;

  define(['spine', 'mediator'], function(spine, mediator) {
    var Cell, data_filter;
    data_filter = function(filter_data, callback) {
      var _this = this;
      return function(data) {
        var k, v;
        for (k in filter_data) {
          v = filter_data[k];
          if (data[k] !== v) {
            return;
          }
        }
        return callback(data);
      };
    };
    return Cell = (function(_super) {

      __extends(Cell, _super);

      Cell.extend(mediator.Mediator);

      function Cell(data) {
        this.id = typeof data === 'number' ? data : data != null ? data.id : void 0;
        this.tokens = {};
        this.fire('cell:init', {
          id: this.id
        });
        mediator.on('cell:set_data', this.handle_set_data);
        mediator.on('cell:get_data', this.handle_get_data);
        this.set_data(data.data);
      }

      Cell._new_cell_id = function() {
        return _last_cell_id += 1;
      };

      Cell.prototype._new_token_id = function() {
        return '' + Date().getTime() + (this.id || '');
      };

      Cell.prototype.set = function(key, value, token, fire, callback) {
        var _this = this;
        if (fire == null) {
          fire = true;
        }
        if (callback == null) {
          callback = function() {};
        }
        console.log("cell [set] " + key + " " + value + " " + token + " " + fire);
        if (!((token != null) || token > this.tokens[key])) {
          callback(false, key, value);
          return;
        }
        token = this.tokens[key] = this._new_token_id();
        return this._set(key, value, function() {
          if (fire) {
            console.log("cells firing set_cell_value");
            _this.fire('cell:set_value', {
              key: key,
              value: value,
              token: token
            });
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

      Cell.prototype.get = function(key) {
        return this.data[key];
      };

      Cell.prototype.get_data = function() {
        return this.data;
      };

      Cell.prototype.set_data = function(data, callback) {
        var done, k, token, total, v, _results,
          _this = this;
        if (callback == null) {
          callback = function() {};
        }
        if (!(data != null ? data.length : void 0)) {
          return;
        }
        token = this._new_token_id();
        total = data.length;
        done = 0;
        _results = [];
        for (k in data) {
          v = data[k];
          _results.push(this.set(k, v, token, false, function(success, key, value) {
            done += 1;
            if (total === done) {
              callback(true, data);
              return _this.fire('cell:set_data', {
                id: _this.id,
                data: data,
                token: token
              });
            }
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
        this.fire('cell:clear', {
          token: token
        });
        return callback(cleared);
      };

      Cell.prototype.handle_set_value = function(data) {
        if (this.id !== id) {
          return;
        }
        return this.set(data);
      };

      Cell.prototype.handle_set_data = function(data) {
        if (this.id !== id) {
          return;
        }
        return this.set_data(data);
      };

      Cell.prototype.fire = mediator.fire;

      return Cell;

    })(Spine.Module);
  });

}).call(this);
