LogStream = require('./src/LogStream').LogStream

###
LogClient creates LogStreams and opens a persistent TCP connection to the server.

On startup it announces itself as Node with Stream associations.
Log messages are sent to the server via string-delimited TCP messages

###
class LogMonitorClient
  constructor: () ->

  init: (conf, primus) ->
    console.log "Init log monitor"

    @socket = primus.channel 'logs-daemons'
    @socket.send 'auth',
      nodeId: conf.nodeId

    @logStreams = (new LogStream name, paths for name, paths of conf.logStreams)
    @_run()

  _run: ->
    @logStreams.forEach (stream) =>
      stream.watch().on 'new_log', (msg) =>
        @_sendLog stream, msg

  _sendLog: (stream, msg) ->
    @socket.send 'new_log', stream.name, msg


module.exports = new LogMonitorClient