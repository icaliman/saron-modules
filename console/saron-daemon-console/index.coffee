exports.init = (conf, primus) ->
  console.log "Init console"

  socket = primus.channel 'console-daemons'

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'command', (command, callback) ->
    callback null, "Result :) " + command
