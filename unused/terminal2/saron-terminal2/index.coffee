console.log 'Saron terminal2 Module'

exports.init = (store, primus) ->
  console.log 'Saron: Init terminal2'

  browsers = primus.channel 'terminal2-browsers'
  daemons = primus.channel 'terminal2-daemons'

  daemonsSockets = {}
  browsersSockets = {}

  browsers.on 'connection', (spark) ->
    console.log 'terminal2: New Browser connection'

    serverId = null

    spark.on 'auth', (sId, cb) ->
      serverId = sId
      browsersSockets[serverId] = spark

      if daemonsSockets[serverId]
        daemon = daemonsSockets[serverId]
        daemon.send 'start'

      cb && cb daemonsSockets[serverId]==null


    spark.on 'command', (command) ->
      console.log 'terminal2 received: ', command, serverId

      if daemonsSockets[serverId]
        daemon = daemonsSockets[serverId]
        daemon.send 'command', command
      else
#        spark.send 'terminal', 'Server is not connected to the app'

  daemons.on 'connection', (spark) ->
    console.log 'terminal2: New Daemon connection'

    serverId = null

    spark.on 'auth', (conf) ->
      console.log "terminal2: Daemon auth", conf
      serverId = conf.nodeId
      daemonsSockets[serverId] = spark

    spark.on 'end', () ->
      if daemonsSockets[serverId]?.id is spark.id
        delete daemonsSockets[serverId]

    spark.on 'terminal', (data) ->
      if browsersSockets[serverId]
        browser = browsersSockets[serverId]
        browser.send 'terminal', data