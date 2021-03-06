utils = require 'saron-utils'

class ColorManager
  max: 20
  curr: 0
  next: ->
    @curr = @curr % @max + 1
    return @curr

class SLogs
  view: __dirname
  name: 's-logs'
  colors: new ColorManager
  colors_mem: {}

#  This is called on the server and in the browser
  init: (model) ->
    @server = model.at 'server'
    model.setNull "logs", []
    @filterChange()

#  This is called only in the browser
  create: (model, dom) ->
    @primus = utils.getPrimus()
    @socket = @primus.channel 'logs-browsers'

    @socket.on 'new_log', (stream, log) =>
      model.insert "logs", 0,
        stream: stream
        message: log
        show_message: @renderLog(log)
        visible: @filterLog(log)

    @socket.send 'auth', @server.get('id')

    model.on 'change', 'server.logs.filter', (filter) =>
      @filterChange()

  filterChange: ->
    filter = @model.get 'server.logs.filter'
    return unless typeof filter is 'string'
    filter = filter.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")
    @filter = if filter then new RegExp "(#{filter})", 'ig' else null
    logs = @model.get "logs"
    for log, i in logs
      @model.set "logs.#{i}.visible", @filterLog log.message
      @model.set "logs.#{i}.show_message", @renderLog log.message


  renderLog: (log) ->
    if @filter
      return log.replace @filter, '<span class="h">$1</span>'
    return log

  filterLog: (log) ->
    if @filter
      return log.match @filter
    return true

  color: (stream) ->
    @colors_mem[stream] = @colors_mem[stream] || @colors.next()
    return "color" + @colors_mem[stream]


module.exports = SLogs