Terminal = require 'term.js/src/term.js'

module.exports = class STerminal
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

#  This is called only in the browser
  create: (model) ->
    @primus = window.primus
    @socket = @primus.channel 'terminal-browsers'

    term = new Terminal
      cols: 80
      rows: 24
      useStyle: true
      screenKeys: true
#      convertEol: true

    term.on 'data', (data) =>
      console.log "Term send: ", data
      @socket.send 'command', data

    term.open document.getElementById('saron-terminal-' + @server.get('id'))

    @socket.on 'terminal', (data) =>
      term.write(data)


    @socket.send 'auth', @server.get('id'), (ok) =>
      if ok then term.write('\x1b[31mConnecting to ' + @server.get('name') + '...\x1b[m');
      else term.write('\x1b[31mServer ' + @server.get('name') + ' is unavailable!\x1b[m');

#    @socket.on 'end', ->
#      term.destroy()