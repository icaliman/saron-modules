module.exports = (app, options) ->
  app.component require('./saron-monitor')
  app.component require('./s-monitor')
#  app.loadStyles __dirname + '/css/term'
