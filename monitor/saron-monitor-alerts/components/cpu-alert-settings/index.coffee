
module.exports = class CpuAlert
  view: __dirname
  name: 'cpu-alerts'

#  This is called on the server and in the browser
  init: (model) ->
    model.setNull 'server.alerts.cpu.value', 95
    model.setNull 'server.alerts.cpu.period', 3600

#  This is called only in the browser
#  create: (model) ->
