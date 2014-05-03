pty = require('peters-pty.js')

shell = null
term = null
socket = null

if process.platform is 'win32'
  shell = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'
#  shell = 'cmd.exe'
else
  shell = process.env.SHELL || 'shell'


exports.init = (conf, primus) ->
  console.log "Init terminal"

  socket = primus.channel 'terminal-daemons'

  createTerminal(conf)

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'command', (data) ->
    createTerminal(conf) unless term
    term.write data

  socket.on 'start', () ->
    console.log 'start: '
    term.destroy() if term
    createTerminal(conf)



#console.log('--=========----------------=========',process.env.HOME)

createTerminal = (conf) ->
  term = pty.fork shell, [],
    name: 'xterm-256color'
    cols: 80
    rows: 25
#    cwd: process.env.HOME
    env: process.env
  #  debug: true

  term.on 'data', (data) ->
#    console.log '---------------------------', data
#    if data.indexOf('set PATH=') == -1
    socket.send 'terminal', data if socket

  term.on 'exit', () ->
    console.log "Terminal exited!!!!!!!!!!!!!!!!!!!"

#  setTimeout (->
#    term.write 'set PATH=' + process.env.PATH + '\r'
#  ), 1000