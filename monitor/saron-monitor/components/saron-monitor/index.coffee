
module.exports = class SaronTerminal
  view: __dirname
  name: 'saron-monitor'

#  This is called on the server and in the browser
  init: (model) ->
#    model.ref 'servers', model.root.at '_page.servers'
#    @server = model.ref 'selectedServer', model.root.at '_page.selectedServer'