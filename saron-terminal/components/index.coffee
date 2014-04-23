module.exports = (app, options) ->
  app.component require('./saron-terminal')
  app.component require('./s-terminal')
  app.loadStyles __dirname + '/css/term'
