console.log 'Saron Monitor Module'

exports.init = (store, primus) ->
  console.log 'Saron: Init monitor'

  browsers = primus.channel 'monitor-browsers'
  daemons = primus.channel 'monitor-daemons'

  daemonsSockets = {}
  browsersSockets = {}

  browsers.on 'connection', (spark) ->
    console.log 'Monitor: New Browser connection'

    serverId = null

    spark.on 'auth', (sId, cb) ->
      serverId = sId
      browsersSockets[serverId] = spark

      if daemonsSockets[serverId]
        daemon = daemonsSockets[serverId]
        daemon.send 'start'

      cb && cb daemonsSockets[serverId]==null


    spark.on 'update', (command) ->
      console.log 'Monitor received: ', command, serverId
      if daemonsSockets[serverId]
        daemon = daemonsSockets[serverId]
        daemon.send 'update', command
      else
#        spark.send 'error', 'Server is not connected to the app'

    spark.on 'end', () ->
      console.log ">>>>>>>>>>>>>>>> BROWSER END CONNECTION >>>>>>>>>>>>>>>>>"
      if browsersSockets[serverId]?.id is spark.id
        delete browsersSockets[serverId]

#        TODO: stop daemon monitor from sending data if needed
        if daemonsSockets[serverId]
          daemon = daemonsSockets[serverId]
          daemon.send 'stop'

    spark.on 'reconnect', () ->
      console.log "================--------------------=================-----------------=================="
    spark.on 'reconnected', () ->
      console.log "000000000000000----------------================--------------------=================-----------------=================="
    spark.on 'open', () ->
      console.log "+++++++++++++----------------================--------------------=================-----------------=================="

  daemons.on 'connection', (spark) ->
    console.log 'Terminal: New Daemon connection'

    serverId = null

    spark.on 'auth', (conf) ->
      console.log "Terminal: Daemon auth", conf
      serverId = conf.nodeId
      daemonsSockets[serverId] = spark

      if browsersSockets[serverId]
        spark.send 'start'


    spark.on 'end', () ->
      if daemonsSockets[serverId]?.id is spark.id
        delete daemonsSockets[serverId]

    spark.on 'update', (data) ->
#      TODO: create statistics with monitoring data
      if browsersSockets[serverId]
        browser = browsersSockets[serverId]
        browser.send 'update', data