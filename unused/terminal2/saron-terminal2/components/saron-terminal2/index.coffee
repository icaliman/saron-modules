
module.exports = class SaronTerminal2
  view: __dirname

#  This is called on the server and in the browser
  init: (model) ->
    model.ref 'servers', model.root.at '_page.servers'
    model.ref 'selectedServer', model.root.at '_page.selectedServer'
