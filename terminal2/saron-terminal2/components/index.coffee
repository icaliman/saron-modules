module.exports = (app, options) ->
  app.component require('./saron-terminal2')
  app.component require('./s-terminal2')
  app.loadStyles __dirname + '/css/term'
