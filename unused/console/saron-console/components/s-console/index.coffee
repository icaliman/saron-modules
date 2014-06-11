module.exports = class Console
  view: __dirname

  create: (model, dom) ->
#    TODO: save commands list to localStorage
    model.setNull('commands', []);
    @server = model.at 'server'

    @primus = window.primus
    @socket = @primus.channel 'console-browsers'

#    @socket.send 'auth', @server.get('id')
    @socket.send 'command', @server.get('id'), 'pwd', (error, result) ->
      console.log "------::", result
      model.set('pwd', result)

  newCommand: ->
    command = @model.del('command')
    index = @model.push('commands', {text: command, pwd: @model.get('pwd')})

    return unless command

    @model.set("waitingResult", true)

    @socket.send 'command', @server.get('id'), command, (err, result, pwd) =>
      @model.set("commands." + (index - 1) + ".result", result)
      @model.set("commands." + (index - 1) + ".error", true) if err
      @model.set("pwd", pwd)

      @model.set("waitingResult", false)
      setTimeout (() =>
        @selectConsoleInput();
      ), 0

  stringify: (e) ->
    if typeof e is 'object'
      return JSON.stringify(e)
    return e && e + ''

  selectConsoleInput: () ->
    @consoleInput.focus()