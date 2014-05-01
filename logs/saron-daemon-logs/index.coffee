
exports.init = (conf, primus) ->
  console.log "Init console"

  socket = primus.channel 'console-daemons'

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'something', (data) ->
    console.log "Something: ", data