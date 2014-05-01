
module.exports = class SaronConsole
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    model.ref 'servers', model.root.at '_page.servers'
    @server = model.ref 'selectedServer', model.root.at '_page.selectedServer'

#  This is called only in the browser
#  create: (model) ->
#    @primus = window.primus
#    @socket = @primus.channel 'console-browsers'
#
#    @socket.send 'command', @server.get('id'), 'pwd', (error, path) ->
#      console.log "------------------------------------------- ", path
#      model.set 'pwd', path
#
#  newCommand: (command, callback) ->
#    try
#      receivedResult = false
#
#      @socket.send 'command', @server.get('id'), command, (error, result) ->
#        receivedResult = true
#        callback error, result
#
#      setTimeout ( ->
#        unless receivedResult
#          callback "Timeout: result can come later"
#      ), 5000
#    catch error
#      callback(error.message);