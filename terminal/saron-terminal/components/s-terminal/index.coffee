Terminal = require 'term.js/src/term.js'
utils = require 'saron-utils'

module.exports = class STerminal
  view: __dirname
  name: 's-terminal'

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'
    model.set 'terminalStyle', 'white'

#  This is called only in the browser
  create: (model, dom) ->
    @primus = utils.getPrimus()
    @socket = @primus.channel 'terminal-browsers'

    @term = new Terminal
      cols: 80
      rows: 25
      useStyle: false
      screenKeys: true
#      convertEol: true

    @term.on 'data', (data) =>
      @socket.send 'write', data

    @term.open @terminalTarget

    @socket.on 'term-data', (data) =>
      @term.write(data)

    @socket.on 'get-size', => @resize()

    @socket.send 'auth', @server.get('id')

    @term.write('\x1b[31mConnecting to ' + @server.get('name') + '...\x1b[m');

    @model.root.on 'change', '_page.contentBox', => @resize()

  resize: () ->
#    return unless @model.root.get '_page.contentBox'
    size = @calculateSize()
    @term.resize size.cols, size.rows
    @socket.send 'resize', size.cols, size.rows

  calculateSize: () ->
#    TODO: calculate char width and height
    box = @model.root.get '_page.contentBox'
    w = 7
    h = 14
    size =
      cols: Math.floor((box.width - 12) / w)
      rows: Math.floor((box.height - 10) / h)
      width: box.width
      height: box.height

  setTerminalStyle: (color) ->
    @model.set 'terminalStyle', color