module.exports = class SaronConsole
  view: __dirname

  init: (model) ->
    model.ref 'servers', model.root.at("_page.servers")
    model.ref "selectedServer", model.root.at "_page.selectedServer"

  newCommand: (command, callback) ->
    try
      callback(null, eval(command));
    catch error
      callback(error.message);