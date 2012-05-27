// Generated by CoffeeScript 1.3.3
(function() {
  var Cell, CellsLookup, app, cells, event_handlers, socket,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  CellsLookup = (function(_super) {

    __extends(CellsLookup, _super);

    function CellsLookup() {
      this.new_token_id = __bind(this.new_token_id, this);
      return CellsLookup.__super__.constructor.apply(this, arguments);
    }

    CellsLookup.include(Spine.Events);

    CellsLookup.prototype.new_token_id = function() {
      return new Date().getTime();
    };

    return CellsLookup;

  })(Spine.Module);

  cells = new CellsLookup();

  event_handlers = {
    set_cell_value: function(data) {
      var id, key, set_value, token, value,
        _this = this;
      id = data.id;
      key = data.key;
      value = data.value;
      token = data.token;
      set_value = function(cell) {
        var token_key;
        token_key = '_' + key;
        if (__indexOf.call(cell, token_key) >= 0) {
          if (token > cell[token_key]) {
            cell[token_key] = token;
          }
        }
        return cell.key = value;
      };
      (cells[id] || []).forEach(function(cell) {
        return set_value(cell);
      });
      return (cells[token] || []).forEach(function(cell) {
        set_value(cell);
        if (!cells[id]) {
          cells[id] = [];
        }
        cells[id].append(cell);
        return cells[token].remove(cell);
      });
    },
    set_cell_data: function(data) {
      var id, k, new_values, token, v, _results;
      id = data.id;
      token = id.token;
      new_values = data.new_values;
      _results = [];
      for (k in new_values) {
        v = new_values[k];
        _results.push(handlers.set_cell_value(id, {
          id: id,
          key: k,
          value: v,
          token: token
        }));
      }
      return _results;
    }
  };

  socket = io.connect();

  socket.on('connect', function() {
    var event_name, handler;
    console.log('connected!');
    for (event_name in event_handlers) {
      handler = event_handlers[event_name];
      socket.on(event_name, handler);
      cells.bind(event_name, handler);
    }
    cells.bind('set_cell_value', function(data) {
      return socket.emit('set_cell_value', data);
    });
    return cells.bind('set_cell_data', function(data) {
      return socket.emit('set_cell_data', data);
    });
  });

  Cell = (function() {

    function Cell(id) {
      this.id = id;
      this.data = {};
    }

    Cell.prototype.set = function(key, value, token, fire) {
      var token_key;
      if (fire == null) {
        fire = true;
      }
      token = cells.new_token_id();
      this.data[key] = value;
      token_key = '_' + key;
      this.data[token_key] = token;
      if (!this.id) {
        if (!cells[token_key]) {
          cells[token_key] = [];
        }
        cells[token_key].push(this);
      }
      return cells.trigger('set_cell_value', {
        id: this.id,
        key: key,
        value: value,
        token: token
      });
    };

    Cell.prototype.get = function(key) {
      return this.data[key];
    };

    Cell.prototype.set_data = function(data) {
      var k, token, v;
      token = cells.new_token_id();
      for (k in data) {
        v = data[k];
        this.set(k, v, token, false);
      }
      return cells.trigger('set_cell_data', {
        id: this.id,
        data: data,
        token: token
      });
    };

    Cell.prototype.clear = function() {
      return this.set_data({});
    };

    return Cell;

  })();

  app = this.app = {};

  app.cells = cells;

  app.Cell = Cell;

}).call(this);
