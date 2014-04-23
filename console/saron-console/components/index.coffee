module.exports = (app, options) ->
  app.component require('d-console')
  app.component require('./saron-console')
  app.loadStyles __dirname + '/css/index'
