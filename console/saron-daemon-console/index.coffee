child = require("child_process")
exec = child.exec

exports.init = (conf, primus) ->
  console.log "Init console"

  socket = primus.channel 'console-daemons'

  socket.send 'auth',
    nodeId: conf.nodeId

  socket.on 'command', (command, callback) ->
    exec command, (err, stdout, stderr) ->
#      dir = process.cwd()
      if command.match(/^cd/) and not stderr
        process.chdir(command.replace(/^cd /, ""))

      exec "pwd", (err, path) ->
#        process.chdir dir

        console.log "===============", path
        console.log "===============", process.cwd()
        console.log "STDOUT: ", stdout
        console.log "STDERR: ", stderr

        if stdout
          callback false, stdout, path
        else
          callback true, stderr, path