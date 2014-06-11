
module.exports = class CpuAlert
  view: __dirname
  name: 'saron-monitor-alerts'
  targetView: 'admin_server_alerts'

#  This is called on the server and in the browser
#  init: (model) ->

#  This is called only in the browser
  create: (model) ->
#    @model.root.on 'change', '_page.selectedServer.alerts.alert**', () ->
#      console.log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", arguments

#    TODO: remove this :)
    setInterval (=>
      model.root.set '_page.selectedServer.alerts.up', true
    ), 1000

  hide: (name) ->
    switch name
      when 'cpu', 'ram'
        @model.root.set '_page.selectedServer.alerts.alert.'+name, false
      when 'disk'
        d = arguments[1]
        @model.root.set '_page.selectedServer.alerts.alert.disk.'+d, false