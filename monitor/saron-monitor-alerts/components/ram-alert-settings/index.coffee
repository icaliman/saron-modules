
module.exports = class CpuAlert
  view: __dirname
  name: 'ram-alerts'

#  This is called on the server and in the browser
  init: (model) ->
    model.setNull 'server.alerts.ram.value', 95
    model.setNull 'server.alerts.ram.period', 3600

#  This is called only in the browser
#  create: (model) ->
