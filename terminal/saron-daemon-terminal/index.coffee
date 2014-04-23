pty = require('pty.js')

termPath = if process.platform is 'win32' then 'C:\\Windows\\System32\\cmd.exe' else 'bash'
term = null
socket = null


exports.init = (conf, primus) ->
  console.log "Init terminal"

  socket = primus.channel 'terminal-daemons'

  createTerminal()

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'command', (data) ->
    createTerminal() unless term
    term.write data

  socket.on 'start', () ->
    console.log 'start: '
    term.destroy() if term
    createTerminal()


createTerminal = () ->
  term = pty.fork termPath, [],
    name: if require('fs').existsSync('/usr/share/terminfo/x/xterm-256color') then 'xterm-256color' else 'xterm'
    cols: 80
    rows: 24
    cwd: process.env.HOME
    env: process.env
  #  debug: true

  term.on 'data', (data) ->
    socket.send 'terminal', data if socket
