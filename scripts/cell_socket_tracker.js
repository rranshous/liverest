// Generated by CoffeeScript 1.3.3
(function() {

  define(['mediator', 'socket_cell_tracker'], function(mediator, socket_cell_tracker) {
    var add_tracking,
      _this = this;
    socket_cell_tracker.on('tracker:add', function(data) {
      var socket;
      socket = cell_socket_tracker.first(data.id);
      return socket.get('tracking_cells', function(err, cells) {
        cells = cells || [];
        cells.push(data.id);
        return socket.set('tracking_cells', cells);
      });
    });
    add_tracking = function(event_data) {
      if (event_data.__connection) {
        return socket_cell_tracker.track(event_data.id, event_data.__connection);
      }
    };
    mediator.on('cell:set_value', add_tracking);
    mediator.on('cell:set_data', add_tracking);
    mediator.on('cell:init', add_tracking);
  });

}).call(this);