SaronAlerts = require('./index.coffee')

console.log SaronAlerts

sa = new SaronAlerts()

sa.on 'test2', ->
  console.log ">>>>>> >>>>> >>>>", arguments

sa.emit 'test', 123, 345, 34543, 435, 43, 5, 43, 5

serverID = "wdef3w4qwerq32434t34t3422rq4rf4aqfaw43a4"

sa.emit 'start-'