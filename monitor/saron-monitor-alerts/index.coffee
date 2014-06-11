events = require 'events'
AlertTests = require './AlertTests'

class SaronAlerts extends events.EventEmitter
  init: (store, primus) ->
    console.log 'Saron: Init alerts'

    @store = store
    @saronMonitor = require 'saron-monitor'
    @alertTests = new AlertTests store
    @initAlerts()

    @saronMonitor.on 'daemon-connected', (serverID, conf) =>
      @initDaemonAlerts serverID, conf
    @saronMonitor.on 'daemon-disconnected', (serverID) =>
#      TODO: remove alert tests

    @saronMonitor.on 'update', (serverID, data) =>
      @alertTests.periodOverflowTest 'ram', serverID, data.memory
      @alertTests.periodOverflowTest 'cpu', serverID, data.cpu

      for disk in data.disk
        @alertTests.overflowTest 'disk', {id: serverID, dn: disk.name}, disk.used

    @saronMonitor.on 'cpu-alerts-changed', (serverID, cpu) => @initCpuTests serverID, cpu
    @saronMonitor.on 'ram-alerts-changed', (serverID, ram) => @initRamTests serverID, ram
    @saronMonitor.on 'disk-alerts-changed', (serverID, diskName, disk) => @initDiskTests serverID, diskName, disk


  initDaemonAlerts: (serverID, conf) ->
    @getServer serverID, (server) =>
      cpu = server.get 'alerts.cpu'
      ram = server.get 'alerts.ram'
      disk = server.get 'alerts.disk'

      unless cpu
        server.set 'alerts.cpu', {value: 95, period: 3600}
      else @initCpuTests serverID, cpu

      unless ram
        server.set 'alerts.ram', {value: 95, period: 3600}
      else @initRamTests serverID, ram

      disks = if conf then conf.disks else Object.keys(disk || {})
      for diskName in disks
        unless disk?[diskName]
          server.set "alerts.disk.#{diskName}", {value: 90}
        else @initDiskTests serverID, diskName, disk[diskName]

  initCpuTests: (serverID, cpu) ->
    if cpu.enabled
      @alertTests.startPeriodOverflowTest('cpu', serverID, cpu.value/100, cpu.period)
    else
      @alertTests.disablePeriodOverflowTest('cpu', serverID)

  initRamTests: (serverID, ram) ->
    if ram.enabled
      @alertTests.startPeriodOverflowTest('ram', serverID, ram.value/100, ram.period) # trebuie preluat din BD
    else
      @alertTests.disablePeriodOverflowTest('ram', serverID)
      
  initDiskTests: (serverID, diskName, disk) ->
    if disk.enabled
      @alertTests.startOverflowTest('disk', {id: serverID, dn: diskName}, disk.value)
    else
      @alertTests.disableOverflowTest('disk', {id: serverID, dn: diskName})
      
  initAlerts: ->
    @alertTests.on 'period-overflow-cpu', (serverID, maxVal, val, period) =>
#      console.log ">>>>>>><<<<<<<<>>>>>>>>> OVERFLOW CPU <<<<<<<<<>>>>>>><<<<<<<"
      @getServer serverID, (server) =>
        unless server.get 'alerts.alert.cpu'
          server.set 'alerts.alert.cpu', true

    @alertTests.on 'period-overflow-ram', (serverID, maxVal, val, period) =>
#      console.log ">>>>>>><<<<<<<<>>>>>>>>> OVERFLOW RAM <<<<<<<<<>>>>>>><<<<<<<"
      @getServer serverID, (server) =>
        unless server.get 'alerts.alert.ram'
          server.set 'alerts.alert.ram', true

    @alertTests.on 'overflow-disk', (s, val) =>
#      console.log ">>>>>>><<<<<<<<>>>>>>>>> OVERFLOW DISK <<<<<<<<<>>>>>>><<<<<<<", s.dn
      @getServer s.id, (server) =>
        unless server.get "alerts.alert.disk.#{s.dn}"
          server.set "alerts.alert.disk.#{s.dn}", true

  getServer: (serverID, cb) ->
    model = @store.createModel()
    server = model.at "servers.#{serverID}"
    server.subscribe (err) =>
      return console.log(err) if err
      cb server
      model.destroy()

module.exports = new SaronAlerts()