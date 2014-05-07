
module.exports = class SMonitor
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

    model.set 'selected', 'cpu'

#  This is called only in the browser
  create: (model) ->
    @primus = window.primus
    @socket = @primus.channel 'monitor-browsers'

    @socket.on 'update', (data) =>
#      console.log "Monitor update: ", data
      model.set 'info', data
      model.push 'cpuData', data.cpu
      model.push 'memoryData', data.memory

    @socket.send 'auth', @server.get('id')
