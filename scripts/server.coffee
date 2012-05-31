# setup our RESTify servr
restify = require 'restify'

# setup our redis client
redis = require 'redis'
rc = redis.createClient 6379, "127.0.0.1"
rc.on 'error', (err) -> console.log "rc error: #{err}"

# setup our native data type's for redis
# TODO: reuse redis client
redback = require('redback').createClient()

# create our restify server, parsing
# post bodies and query strings
server = restify.createServer()
server.use restify.bodyParser()
server.use restify.queryParser()

get_cell_hash = (id) ->
    redback.createHash "cell:#{id}"

get_next_cell_id = (callback) ->
    rc.incr 'cell:counter', (err, id) ->
        console.log "Got cell counter: #{id}"
        callback id

cell_handlers =

    # the get returns the cell's data
    get: (req, res, next) ->
        console.log "Get request"

        # the params should include the cell's id
        # and a json obj of what data should be set
        hash = get_cell_hash req.params.id

        # get the hash's data
        hash.get (err, obj) ->
            console.log "Get #{req.params.id}:"
            console.log obj
            res.send obj

        return next()


    head: (req, res, next) ->
        return cell_handlers.get req, res, next

    post: (req, res, next) ->
        console.log "Post request:"
        console.log req.params

        # callback for setting the cell data
        set_data = (data) ->

            # get the hash
            hash = get_cell_hash data.id

            # update the hash's data
            hash.set req.params, (err, resp) ->
                console.log "Set #{data.id}:"
                console.log data
                # send the response back to the requester
                res.send data

        # if we already have an id, just set the data
        if req.params.id
            console.log "key found: #{req.params.id}"
            set_data req.params

        # if we dont have an id, set one than set data
        else
            console.log "key not found"
            # get the next ID to assign
            get_next_cell_id (cell_id) ->

                # update it on the params
                req.params.id = cell_id
                set_data req.params

        return next()

    put: (req, res, next) ->
        return cell_handlers.get req, res, next

    del: (req, res, next) ->
        console.log "Del request"

        # get the hash
        hash = get_cell_hash req.params.id

        # delete the hash
        hash.destroy (err, resp) ->
            console.log "Destroyed #{req.params.id}: #{resp}"

        return next()


# setup our routes for RESTing the cells
for method in ['get','head','put','del']
    console.log "setting up #{method} handler"
    server[method] '/cell/:id', cell_handlers[method]
server.post '/cell', cell_handlers.post

# RESTify listen
server.listen 8081, -> console.log "#{server.name} listening at #{server.url}"
