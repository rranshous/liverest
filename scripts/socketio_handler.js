// Generated by CoffeeScript 1.3.3
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['mediator'], function(mediator) {
    var handle_server, handle_socket;
    handle_socket = function(socket) {
      var _this = this;
      mediator.instance_extend(socket);
      socket.on((function(e, d, r) {
        return respond(true);
      }), mediator.fire);
      return mediator.on(function(event, data, respond) {
        if (data.id) {
          return socket.get('tracking_cells', function(err, cells) {
            var _ref;
            return respond(true)((_ref = data.id, __indexOf.call(cells || [], _ref) >= 0) ? void 0 : respond(false));
          });
        } else {
          return respond(false);
        }
      }, function(event, event_data) {
        event_data.__connection = socket;
        return socket.fire(event, event_data);
      });
    };
    handle_server = function(server) {
      return server.on('connection', handle_socket);
    };
    return {
      handle_server: handle_server,
      handle_socket: handle_socket
    };
  });

}).call(this);
