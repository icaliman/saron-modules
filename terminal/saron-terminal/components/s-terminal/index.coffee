Terminal = require 'term.js/src/term.js'

module.exports = class STerminal
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'

#  This is called only in the browser
  create: (model, dom) ->
    @primus = window.primus
    @socket = @primus.channel 'terminal-browsers'

    @term = new Terminal
      cols: 80
      rows: 25
      useStyle: true
      screenKeys: true
#      convertEol: true

    @term.on 'data', (data) =>
      console.log "Term send: ", data
      @socket.send 'write', data

    @term.open document.getElementById('saron-terminal-' + @server.get('id'))

    @socket.on 'term-data', (data) =>
      console.log '-=-=-=-=-=', data
      @term.write(data)

    @socket.send 'auth', @server.get('id')

    @term.write('\x1b[31mConnecting to ' + @server.get('name') + '...\x1b[m');
#      else @term.write('\x1b[31mServer ' + @server.get('name') + ' is unavailable!\x1b[m');

#    @socket.on 'end', ->
#      term.destroy()

    @resize()
    @model.root.on 'change', '_page.contentBox', => @resize()

  resize: () ->
    console.log 'resize'
    size = @calculateSize()
    @term.resize size.cols, size.rows
    @socket.send 'resize', size.cols, size.rows

  calculateSize: () ->
#    TODO: calculate char width and height
    w = 7
    h = 14
    box = @model.root.get '_page.contentBox'
    size =
      cols: Math.floor (box.width - 10) / w
      rows: Math.floor (box.height - 10) / h
      width: box.width
      height: box.height