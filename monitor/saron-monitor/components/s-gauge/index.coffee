
module.exports = class SCPU
  view: __dirname

#  This is called on the server and in the browser
#  init: (model) ->
#    @server = model.at 'server'

#  This is called only in the browser
  create: (model) ->
    value = model.get('info')*100 || 0
    opts = {
      lines: 12, # The number of lines to draw
      angle: 0.15, # The length of each line
      lineWidth: 0.44, # The line thickness
      pointer: {
        length: 0.9, # The radius of the inner circle
        strokeWidth: 0.035, # The rotation offset
        color: '#000000' # Fill color
      },
      limitMax: 'false',   # If true, the pointer will not go past the end of the gauge
      colorStart: '#6FADCF',   # Colors
      colorStop: '#8FC0DA',    # just experiment with them
      strokeColor: '#E0E0E0',   # to see which ones work best for you
      generateGradient: true
    };
    gauge = new Gauge(@gaugeTarget).setOptions(opts); # create sexy gauge!
    gauge.maxValue = 100; # set max gauge value
#    gauge.animationSpeed = 128; # set animation speed (32 is default value)

    model.on 'all', 'info**', (path, method, value) ->
      gauge.set(value*100); # set actual value

#    console.log value

#    console.log @gauseTarget
#    for a in @gauseTarget
#      console.log '------', a
#    for a of @gauseTarget
#      console.log '++++++', a
