module.exports = (app, options) ->
  app.component require('./s-logs')
  app.component require('./saron-logs')
  app.loadStyles __dirname + '/css/index'
