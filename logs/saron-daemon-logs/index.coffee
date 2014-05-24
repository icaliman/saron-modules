LogStream = require('./src/LogStream').LogStream

exports.init = (conf, primus) ->
  console.log "Init log monitor"

  socket = primus.channel 'console-daemons'
  socket.send 'auth',
    nodeId: conf.nodeId

  client = new LogClient conf
  client.socket = socket
  client.run()




###
LogClient creates LogStreams and opens a persistent TCP connection to the server.

On startup it announces itself as Node with Stream associations.
Log messages are sent to the server via string-delimited TCP messages

###
class LogClient
  constructor: (config) ->
    @logStreams = (new LogStream s, paths for s, paths of config.logStreams)

  run: ->
    @logStreams.forEach (stream) =>
      stream.watch().on 'new_log', (msg) =>
        @_sendLog stream, msg

  _sendLog: (stream, msg) ->
    @socket.send 'new_log', stream.name, msg