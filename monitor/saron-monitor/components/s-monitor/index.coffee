
module.exports = class SMonitor
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

#  This is called only in the browser
  create: (model) ->
    @primus = window.primus
    @socket = @primus.channel 'monitor-browsers'

    model.set 'selected', 'cpu'

    @socket.on 'update', (data) =>
#      console.log "Monitor update: ", data
      model.set 'info', data
      model.push 'cpuData', data.cpu
      model.push 'memoryData', data.memory

    @socket.send 'auth', @server.get('id'), (ok) =>
      console.log "Monitor auth: ", ok
