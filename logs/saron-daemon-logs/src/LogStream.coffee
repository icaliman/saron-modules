
fs = require 'fs'
net = require 'net'
events = require 'events'

###
LogStream is a group of local files paths.  It watches each file for
changes, extracts new log messages, and emits 'new_log' events.

###
class LogStream extends events.EventEmitter
  constructor: (@name, @paths) ->
    @_log = console.log

  watch: ->
    @_log.info "Starting log stream: '#{@name}'"
    @_watchFile path for path in @paths
    @

  _watchFile: (path) ->
    if not fs.existsSync path
      @_log.error "File doesn't exist: '#{path}'"
      setTimeout (=> @_watchFile path), 1000
      return
    @_log.info "Watching file: '#{path}'"
    currSize = fs.statSync(path).size
    watcher = fs.watch path, (event, filename) =>
      if event is 'rename'
        # File has been rotated, start new watcher
        watcher.close()
        @_watchFile path
      if event is 'change'
        # Capture file offset information for change event
        fs.stat path, (err, stat) =>
          @_readNewLogs path, stat.size, currSize
          currSize = stat.size

  _readNewLogs: (path, curr, prev) ->
    # Use file offset information to stream new log lines from file
    return if curr < prev
    rstream = fs.createReadStream path,
      encoding: 'utf8'
      start: prev
      end: curr
    # Emit 'new_log' event for every captured log line
    rstream.on 'data', (data) =>
      lines = data.split "\n"
      @emit 'new_log', line for line in lines when line

exports.LogStream = LogStream