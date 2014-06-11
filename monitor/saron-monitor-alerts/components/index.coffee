module.exports = (app, options) ->
  app.component require('./cpu-alert-settings')
  app.component require('./ram-alert-settings')
  app.component require('./disk-alert-settings')
  app.component require('./alerts')
  app.component require('./alerts-settings')
