#LogStream = require('../src/LogStream').LogStream
#
#stream = new LogStream('TestStream', ['./test_logs.txt'])
#stream.watch()
#
#stream.on 'new_log', (msg) ->
#  console.log 'new_log', stream.name, msg


fs = require 'fs'

add_log = ->
  fs.appendFile './test_logs.txt', 'new log string\nnew log string\n', (err) ->
    console.log "ERROR: ", err if err


add_log()
setInterval add_log, 5000