console.log 'Saron Console Module'

exports.init = (store, primus) ->
  console.log 'Saron: Init console'

  browsers = primus.channel 'console-browsers'
  daemons = primus.channel 'console-daemons'

  daemonsSockets = {}

  browsers.on 'connection', (spark) ->
    console.log 'Console: New Browser connection'

    console.log "Spark ID: ", spark.id

    spark.on 'command', (serverId, command, cb) ->
      console.log 'Console received: ', command, serverId
      if daemonsSockets[serverId]
        daemon = daemonsSockets[serverId]
        daemon.send 'command', command, cb
      else
        cb "Server is not connected to the app"

  daemons.on 'connection', (spark) ->
    console.log 'Console: New Daemon connection'

    serverId = null

    spark.on 'auth', (conf) ->
      console.log "Console: Daemon auth", conf
      serverId = conf.nodeId
      daemonsSockets[serverId] = spark

    spark.on 'end', () ->
      if daemonsSockets[serverId]?.id is spark.id
        delete daemonsSockets[serverId]