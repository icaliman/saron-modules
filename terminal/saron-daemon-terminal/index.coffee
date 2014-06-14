pty_os_module = if process.platform is 'win32' then 'peters-pty.js' else 'pty.js'
pty = require pty_os_module

shell = null
term = null
socket = null
lastOutput = null # send this if terminal is opened in multiple tabs

if process.platform is 'win32'
#  shell = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'
  shell = 'powershell.exe'
#  shell = 'cmd.exe'
else
  shell = process.env.SHELL || 'bash'


exports.init = (conf, primus) ->
  console.log "Init terminal"

  socket = primus.channel 'terminal-daemons'

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'write', (data) ->
    createTerminal(conf) unless term
    term.write data

  socket.on 'start', () ->
    unless term
      createTerminal(conf)
    else
      socket.send 'term-data', lastOutput
#    term.destroy() if term
#    createTerminal(conf)

  socket.on 'resize', (cols, rows) ->
    term.resize cols, rows if term

createTerminal = (conf) ->
  term = pty.fork shell, [],
    name: 'xterm-256color'
    cols: 80
    rows: 25
    cwd: process.env.PWD || process.env.HOME
    env: process.env
  #  debug: true

  term.on 'data', (data) ->
    socket.send 'term-data', data if socket
    lastOutput = data

  term.on 'exit', () ->
    console.log "Terminal exited!!!!!!!!!!!!!!!!!!!"
    term = null
    lastOutput = null