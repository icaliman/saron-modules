module.exports = (app, options) ->
  app.component require('./saron-terminal2/index')
  app.component require('./s-terminal2/index')
  app.loadStyles __dirname + '/css/term'
