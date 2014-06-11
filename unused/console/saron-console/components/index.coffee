module.exports = (app, options) ->
  app.component require('./s-console')
  app.component require('./saron-console/index')
  app.loadStyles __dirname + '/css/index'
