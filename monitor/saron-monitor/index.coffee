
class SaronMonitor
  init: (store, primus) ->
    console.log 'Saron: Init monitor'

    browsers = primus.channel 'monitor-browsers'
    daemons = primus.channel 'monitor-daemons'

    daemonsSockets = {}

    browsers.on 'connection', (spark) ->
      console.log 'Monitor: New Browser connection'

      serverId = null

      spark.on 'auth', (sId) ->
        serverId = sId
        spark.join serverId

        if daemonsSockets[serverId]
          daemon = daemonsSockets[serverId]
          daemon.send 'start'

      spark.on 'update', (command) ->
        console.log 'Monitor received: ', command, serverId
        if daemonsSockets[serverId]
          daemon = daemonsSockets[serverId]
          daemon.send 'update', command
        else
  #        spark.send 'error', 'Server is not connected to the app'

      spark.on 'end', () ->
        console.log ">>>>>>>>>>>>>>>> MONITOR: BROWSER SOCKET END CONNECTION >>>>>>>>>>>>>>>>>"
  #      TODO: stop daemon monitor from sending data only if needed
  #      if daemonsSockets[serverId]
  #        daemon = daemonsSockets[serverId]
  #        console.log ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> STOP >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  #        daemon.send 'stop'

    daemons.on 'connection', (spark) ->
      console.log 'Monitor: New Daemon connection'
      serverId = null

      spark.on 'auth', (conf) ->
        console.log "Monitor: Daemon auth", conf
        serverId = conf.nodeId
        daemonsSockets[serverId] = spark
#        unless browsers.isRoomEmpty(serverId)
        spark.send 'start'

      spark.on 'end', () ->
        if daemonsSockets[serverId]?.id is spark.id
          delete daemonsSockets[serverId]

      spark.on 'update', (data) ->
  #      TODO: create statistics with monitoring data
        browsers.room(serverId).send 'update', data

module.exports = new SaronMonitor()