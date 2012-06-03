
# once a socketio connection has been made to another client
# we handle it

define ['mediator'], (mediator) ->

  handle_socket = (socket) ->

    console.log 'handling socket'

    # update the socket so that it has better (internal) event support
    mediator.Eventable.instance_extend socket

    # when an event comes in, it needs to go through the mediator
    socket.on ((e,d,respond) -> respond(true)), (event, data) =>

      console.log
        socket_on: [event, data]

      # if this is an outgoing event, dont process
      return if data?.__outgoing

      # refire the event through the mediator w/ the socket in the data
      # TODO: use something more generic than connection, something
      #       which signifies it's a proxy for the firing object
      data.__connection = socket
      console.log
        firing_socket: socket
      mediator.fire event, data

    # when the mediator puts off an event, we need to check if
    # has to do with a cell this socket cares about, if so relay
    # the event to the socket
    mediator.on \

      # this function checks if the event is one the socket will care about
      (event, data, respond) =>

        console.log "mediator event check"
        console.log 
          event:event,
          data:data

        # check if the data has to do with a cell the socket cares about
        if data.id

          # to figure out if we care check the list of the sockets tracked cells
          socket.get 'tracking_cells', (err, cells) =>
            respond(true) if data.id in (cells or []) else respond(false)

        else
          
          # if the cell doesn't have an id than just pass on through
          respond(true) 

      # this function handles cells from the mediator
      # we've already decided we want them, just pass them on
    , (event, event_data) =>

      event_data.__outgoing = true
      socket.fire event, event_data

  handle_server = (server) ->

    # just push sockets to handle_socket as they connect
    server.on 'connection', handle_socket

  handle_server: handle_server,
  handle_socket: handle_socket
