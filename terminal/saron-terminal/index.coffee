console.log 'Saron Terminal Module'

exports.init = (store, primus) ->
  console.log 'Saron: Init terminal'

  browsers = primus.channel 'terminal-browsers'
  daemons = primus.channel 'terminal-daemons'

  daemonsSockets = {}
  browsersSockets = {}

  browsers.on 'connection', (spark) ->
#    console.log 'Terminal: New Browser connection'
    serverId = null

    spark.on 'auth', (sId, cb) ->
      serverId = sId
      browsersSockets[serverId] = spark
      if daemonsSockets[serverId]
        daemon = daemonsSockets[serverId]
        daemon.send 'start'
      cb && cb daemonsSockets[serverId]==null

    spark.on 'data', (data) ->
      unless data.data[0] in ['auth']
        if daemonsSockets[serverId]
          daemon = daemonsSockets[serverId]
          daemon.write data
        else
#          spark.send 'terminal', 'Server is not connected to the app'


  daemons.on 'connection', (spark) ->
#    console.log 'Terminal: New Daemon connection'
    serverId = null

    spark.on 'auth', (conf) ->
#      console.log "Terminal: Daemon auth", conf
      serverId = conf.nodeId
      daemonsSockets[serverId] = spark

    spark.on 'end', () ->
      if daemonsSockets[serverId]?.id is spark.id
        delete daemonsSockets[serverId]

    spark.on 'term-data', (data) ->
      if browsersSockets[serverId]
        browser = browsersSockets[serverId]
        browser.send 'term-data', data