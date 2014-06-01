utils = require 'saron-utils'

module.exports = class SMonitor
  view: __dirname
  name: 's-monitor'

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

    model.set 'selected', 'cpu'

#  This is called only in the browser
  create: (model) ->
    @primus = utils.getPrimus()
    @socket = @primus.channel 'monitor-browsers'

    model.set 'diskData', []

    @socket.on 'update', (data) =>
      model.push 'cpuData', data.cpu
      model.push 'memoryData', data.memory
#      model.set 'diskData', data.disk

      for drive, i in data.disk
        model.set "diskData.#{i}.name", data.disk[i].name
        model.set "diskData.#{i}.total", data.disk[i].total
        model.set "diskData.#{i}.free", data.disk[i].free
        model.set "diskData.#{i}.used", data.disk[i].used

#      Total disk usage calculation
      diskTotal = 0
      diskFree = 0
      for drive in data.disk
        diskTotal += drive.total
        diskFree += drive.free
      data.disk = (1 - diskFree / diskTotal)
      model.set 'info', data

#      TODO: place this in another place?
      unless @server.get 'connected'
        @server.set 'connected', true

    @socket.send 'auth', @server.get('id')
