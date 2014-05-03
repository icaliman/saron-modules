pty = require('peters-pty.js')

term = pty.fork 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe', [],
  name: 'aaa'
  cols: 80
  rows: 25
  cwd: process.env.HOME
  env: process.env

term.on 'data', (data) ->
  console.log data

term.on 'exit', () ->
  console.log "Terminal exited."

