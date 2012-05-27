var io = require('socket.io');
var express = require('express')
var app = express.createServer()
app.use(express.static(__dirname));
io = io.listen(app);

app.listen(8080);

io.sockets.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});
