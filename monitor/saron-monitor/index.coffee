events = require 'events'

class SaronMonitor extends events.EventEmitter
  init: (store, primus) ->
    console.log 'Saron: Init monitor'

    @store = store

    browsers = primus.channel 'monitor-browsers'
    daemons = primus.channel 'monitor-daemons'

    daemonsSockets = {}

    browsers.on 'connection', (spark) =>
      console.log 'Monitor: New Browser connection'

      serverID = null

      spark.on 'auth', (sId) =>
        serverID = sId
        spark.join serverID

        if daemonsSockets[serverID]
          daemon = daemonsSockets[serverID]
          daemon.send 'start'

      spark.on 'cpu-alerts-changed', (cpu) => @emit 'cpu-alerts-changed', serverID, cpu
      spark.on 'ram-alerts-changed', (ram) => @emit 'ram-alerts-changed', serverID, ram
      spark.on 'disk-alerts-changed', (diskName, disk) => @emit 'disk-alerts-changed', serverID, diskName, disk

      spark.on 'end', () =>
        console.log ">>>>>>>>>>>>>>>> MONITOR: BROWSER SOCKET END CONNECTION >>>>>>>>>>>>>>>>>"

    daemons.on 'connection', (spark) =>
      console.log 'Monitor: New Daemon connection'
      serverID = null

      spark.on 'auth', (conf) =>
        console.log "Monitor: Daemon auth", conf
        serverID = conf.nodeId
        daemonsSockets[serverID] = spark
        spark.send 'start'
        @emit 'daemon-connected', serverID, conf

      spark.on 'end', () ->
        if daemonsSockets[serverID]?.id is spark.id
          delete daemonsSockets[serverID]
          @emit 'daemon-disconnected', serverID

      spark.on 'update', (data) =>
        browsers.room(serverID).send 'update', data
        @emit 'update', serverID, data

module.exports = new SaronMonitor()