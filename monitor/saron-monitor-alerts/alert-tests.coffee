events = require 'events'

class AlertTests extends events.EventEmitter
  constructor: (@store) ->
#    TODO: save in DB? store.createModel()
    @maxVals = {}
    @maxValsPeriod = {}

  startOverflowTest: (key, id, maxVal) ->
    sid = if typeof id is 'string' then id else JSON.stringify(id)
    @maxVals[key] = @maxVals[key] || {}
    @maxVals[key][sid] = maxVal

  disableOverflowTest: (key, id) ->
    sid = if typeof id is 'string' then id else JSON.stringify(id)
    delete @maxVals[key][sid] if @maxVals[key]?[sid]

  overflowTest: (key, id, val) ->
    sid = if typeof id is 'string' then id else JSON.stringify(id)
#    return console.log("Overflow test \"#{key}\" was not started for id: #{sid}!") unless @maxVals[key]?[sid]
    return  unless @maxVals[key]?[sid]
    if val > @maxVals[key][sid]
      @emit 'overflow-' + key, id, val


  startPeriodOverflowTest: (key, id, maxVal, period) ->
#    console.log "START: ", arguments
    sid = if typeof id is 'string' then id else JSON.stringify(id)
    @maxValsPeriod[key] = @maxValsPeriod[key] || {}
    @maxValsPeriod[key][sid] = {maxVal, period, startDate: Date.now()} # TODO: startDate trebuie setat la prima depasire ???

  disablePeriodOverflowTest: (key, id) ->
#    console.log "DISABLE: ", arguments
    sid = if typeof id is 'string' then id else JSON.stringify(id)
    delete @maxValsPeriod[key][sid] if @maxValsPeriod[key]?[sid]

  periodOverflowTest: (key, id, val) ->
    sid = if typeof id is 'string' then id else JSON.stringify(id)
#    return console.log("Overflow period test \"#{key}\" was not started for id: #{sid}!") unless @maxValsPeriod[key]?[sid]
    return unless @maxValsPeriod[key]?[sid]
    if val > @maxValsPeriod[key][sid].maxVal
      start = @maxValsPeriod[key][sid].startDate
      now = Date.now()
      dtime = (now - start) / 1000 # timpul scurs in secunde de cand avem depasire
      if dtime > @maxValsPeriod[key][sid].period
        @emit 'period-overflow-' + key, id, @maxValsPeriod[key][sid].maxVal, val, dtime
        @maxValsPeriod[key][sid].startDate = Date.now()
    else
      @maxValsPeriod[key][sid].startDate = Date.now()

module.exports = AlertTests