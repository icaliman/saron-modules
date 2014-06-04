monitor = require './monitoring'
socket = null
started = false
interval = false

exports.init = (conf, primus) ->
  console.log "Init monitor"

  monitor.init conf

  socket = primus.channel 'monitor-daemons'

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'update', (data) ->
    sendData monitor.usage()

  socket.on 'start', () ->
    return if started
    started = true
    interval = monitor.usageInterval 1000, sendData

  socket.on 'stop', () ->
    clearInterval(interval) if interval
    started = false


sendData = (data) ->
  socket.send 'update', data