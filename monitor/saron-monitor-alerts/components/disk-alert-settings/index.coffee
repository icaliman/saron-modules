
module.exports = class CpuAlert
  view: __dirname
  name: 'disk-alerts'

#  This is called on the server and in the browser
  init: (model) ->
#    model.set 'server.alerts.disk.C.value', 95
    model.set 'drives', Object.keys(model.get('server.alerts.disk') || {})

    model.on 'change', 'server', () ->
      model.set 'drives', Object.keys(model.get('server.alerts.disk') || {})

    model.on 'change', 'server.alerts.disk', () ->
      model.set 'drives', Object.keys(model.get('server.alerts.disk') || {})


#  This is called only in the browser
#  create: (model) ->