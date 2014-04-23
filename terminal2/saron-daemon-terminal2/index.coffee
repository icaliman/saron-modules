spawn = require('child_process').spawn

term = null
socket = null
isCommand = false


exports.init = (conf, primus) ->
  console.log "Init terminal2"

  socket = primus.channel 'terminal2-daemons'

  createTerminal()

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'command', (data) ->
    createTerminal() unless term
#    if data.indexOf('\r') != -1
    data += '\n'
    isCommand = true
    term.stdin.write data

  socket.on 'start', () ->
    console.log 'Terminal2: Start'
    term.kill() if term
    createTerminal()


createTerminal = () ->
  term = spawn 'cmd'

  term.stdin.setEncoding = 'utf-8'

  isFirst = true

  term.stdout.on 'data', (data) ->
    unless isCommand
      socket.send 'terminal', '\r'+(unless isFirst then '\n' else '')+data if socket
    isCommand = false
    isFirst = false

  term.stderr.on 'data', (data) ->
    socket.send 'terminal', '\r\n'+data if socket

  term.on 'close', (code) ->
    console.log "TERMINAL2: Child process exited with code: ", code