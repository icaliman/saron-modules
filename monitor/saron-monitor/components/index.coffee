module.exports = (app, options) ->
  app.component require('./saron-monitor')
  app.component require('./s-monitor')
  app.component require('./s-bar')
  app.component require('./s-gauge')
  app.component require('./s-line-chart')
  app.loadStyles __dirname + '/css/index'
