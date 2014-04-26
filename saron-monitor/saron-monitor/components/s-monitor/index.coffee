Terminal = require 'term.js/src/term.js'

module.exports = class STerminal
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

#  This is called only in the browser
  create: (model) ->
    @primus = window.primus
    @socket = @primus.channel 'monitor-browsers'

    @socket.on 'update', (data) =>
      console.log "Monitor update: ", data

    @socket.send 'auth', @server.get('id'), (ok) =>
      console.log "Monitor auth: ", ok
