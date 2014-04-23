Terminal = require 'term.js/src/term.js'

module.exports = class STerminal2
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

#  This is called only in the browser
  create: (model) ->
    console.log "---------------------------------------------------"
    @primus = window.primus
    @socket = @primus.channel 'terminal2-browsers'
    command = ''

    @term = new Terminal
      cols: 80
      rows: 24
      useStyle: true
      screenKeys: true
#      convertEol: true

    @term.on 'data', (data) =>
      console.log "Term send: ", data=='\r'
      if data is '\r'
        @socket.send 'command', command
        command = ''
      else
        command += data
#        @term.write data

    @term.open document.getElementById('saron-terminal2-' + @server.get('id'))

    @socket.on 'terminal', (data) =>
      @term.write(data)


    @socket.send 'auth', @server.get('id'), (ok) =>
      if ok then @term.write('\x1b[31mConnecting to ' + @server.get('name') + '...\x1b[m');
      else @term.write('\x1b[31mServer ' + @server.get('name') + ' is unavailable!\x1b[m');

#    @socket.on 'end', ->
#      term.destroy()

  newCommand: ->
    @socket.send 'command', @terminalInput.value
    @term.write @terminalInput.value
    @terminalInput.value = ""