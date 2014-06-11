module.exports = (app, options) ->
  app.component require('d-console')
  app.component require('./saron-console/index')
  app.loadStyles __dirname + '/css/index'
