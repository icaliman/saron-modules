console.log 'Saron Terminal Module'

exports.init = (store, primus) ->
  console.log 'Saron: Init terminal'

  browsers = primus.channel 'logs-browsers'
  daemons = primus.channel 'logs-daemons'

  daemonsSockets = {}

  browsers.on 'connection', (spark) ->
#    console.log 'Terminal: New Browser connection'
    serverId = null

    spark.on 'auth', (sId) ->
      serverId = sId
      spark.join serverId

#      if daemonsSockets[serverId]
#        daemon = daemonsSockets[serverId]

  daemons.on 'connection', (spark) ->
#    console.log 'Terminal: New Daemon connection'
    serverId = null

    spark.on 'auth', (conf) ->
#      console.log "Terminal: Daemon auth", conf
      serverId = conf.nodeId
      daemonsSockets[serverId] = spark
    #      spark.join serverId

    spark.on 'end', () ->
      if daemonsSockets[serverId]?.id is spark.id
        delete daemonsSockets[serverId]

    spark.on 'new_log', (stream, log) ->
      browsers.room(serverId).send 'new_log', stream, log