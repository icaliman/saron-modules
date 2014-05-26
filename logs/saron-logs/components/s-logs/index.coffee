
module.exports = class SLogs
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

#  This is called only in the browser
  create: (model, dom) ->
    @primus = window.primus
    @socket = @primus.channel 'logs-browsers'

    @socket.on 'new_log', (stream, log) =>
      model.push "logs", log

    @socket.send 'auth', @server.get('id')