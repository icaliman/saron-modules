SaronAlerts = require 'saron-alerts'


class SaronMonitor
  init: (store, primus) ->
    console.log 'Saron: Init monitor'

    @store = store
    @saronAlerts = new SaronAlerts store
    @initAlerts()

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

      spark.on 'cpu-alerts-changed', (cpu) =>
        if cpu.enabled
          @saronAlerts.startPeriodOverflowTest('cpu', serverID, cpu.value/100, cpu.period)
        else
          @saronAlerts.disablePeriodOverflowTest('cpu', serverID)
      spark.on 'ram-alerts-changed', (ram) =>
        if ram.enabled
          @saronAlerts.startPeriodOverflowTest('ram', serverID, ram.value/100, ram.period)
        else
          @saronAlerts.disablePeriodOverflowTest('ram', serverID)
      spark.on 'disk-alerts-changed', (disk) =>
        if disk.enabled
          @saronAlerts.startOverflowTest('disk', {id: serverID, dn: disk.name}, disk.value)
        else
          @saronAlerts.disableOverflowTest('disk', {id: serverID, dn: disk.name})

      spark.on 'end', () =>
        console.log ">>>>>>>>>>>>>>>> MONITOR: BROWSER SOCKET END CONNECTION >>>>>>>>>>>>>>>>>"
  #      TODO: stop daemon monitor from sending data only if needed
  #      if daemonsSockets[serverID]
  #        daemon = daemonsSockets[serverID]
  #        console.log ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> STOP >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  #        daemon.send 'stop'

    daemons.on 'connection', (spark) =>
      console.log 'Monitor: New Daemon connection'
      serverID = null

      spark.on 'auth', (conf) =>
        console.log "Monitor: Daemon auth", conf
        serverID = conf.nodeId
        daemonsSockets[serverID] = spark
#        unless browsers.isRoomEmpty(serverID)
        spark.send 'start'

        @initDaemonAlerts serverID, conf

      spark.on 'end', () ->
        if daemonsSockets[serverID]?.id is spark.id
          delete daemonsSockets[serverID]

      spark.on 'update', (data) =>
  #      TODO: create statistics with monitoring data
        @saronAlerts.periodOverflowTest 'ram', serverID, data.memory
        @saronAlerts.periodOverflowTest 'cpu', serverID, data.cpu

        for disk in data.disk
          @saronAlerts.overflowTest 'disk', {id: serverID, dn: disk.name}, disk.used

        browsers.room(serverID).send 'update', data

  initDaemonAlerts: (serverID, conf) ->
    console.log "INIT ALERTS FOR: ", serverID

    model = @store.createModel({fetchOnly: true})
    server = model.at "servers.#{serverID}"
    server.fetch (err) =>
      return console.log(err) if err
      cpu = server.get 'alerts.cpu'
      ram = server.get 'alerts.ram'
      disk = server.get 'alerts.disk'

      unless cpu
        server.set 'alerts.cpu', {value: 95, period: 3600}
      else if cpu.enabled
        @saronAlerts.startPeriodOverflowTest('cpu', serverID, cpu.value/100, cpu.period)
      else
        @saronAlerts.disablePeriodOverflowTest('cpu', serverID)

      unless ram
        server.set 'alerts.ram', {value: 95, period: 3600}
      else if ram.enabled
        @saronAlerts.startPeriodOverflowTest('ram', serverID, ram.value/100, ram.period) # trebuie preluat din BD
      else
        @saronAlerts.disablePeriodOverflowTest('ram', serverID)

      disks = if conf then conf.disks else Object.keys(disk || {})
      for diskName in disks
        unless disk?[diskName]
          server.set "alerts.disk.#{diskName}", {value: 90}
        else if disk[diskName].enabled
          @saronAlerts.startOverflowTest('disk', {id: serverID, dn: diskName}, disk[diskName].value)
        else
          @saronAlerts.disableOverflowTest('disk', {id: serverID, dn: diskName})

  initAlerts: ->
    @saronAlerts.on 'period-overflow-cpu', (serverID, maxVal, val, period) =>
      console.log ">>>>>>><<<<<<<<>>>>>>>>> OVERFLOW CPU <<<<<<<<<>>>>>>><<<<<<<"

    @saronAlerts.on 'period-overflow-ram', (serverID, maxVal, val, period) =>
      console.log ">>>>>>><<<<<<<<>>>>>>>>> OVERFLOW RAM <<<<<<<<<>>>>>>><<<<<<<"

    @saronAlerts.on 'overflow-disk', (server, val) =>
      console.log ">>>>>>><<<<<<<<>>>>>>>>> OVERFLOW DISK <<<<<<<<<>>>>>>><<<<<<<", server.dn

module.exports = new SaronMonitor()