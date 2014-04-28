module.exports = (app, options) ->
  app.component require('./saron-monitor')
  app.component require('./s-monitor')
  app.component require('./s-bar')
  app.loadStyles __dirname + '/css/index'
