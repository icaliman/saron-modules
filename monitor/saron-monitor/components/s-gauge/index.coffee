
module.exports = class SCPU
  view: __dirname
  name: 's-gauge'

#  This is called on the server and in the browser
#  init: (model) ->
#    @server = model.at 'server'

#  This is called only in the browser
  create: (model) ->

    opts = {
      lines: 12, # The number of lines to draw
      angle: 0.15, # The length of each line
      lineWidth: 0.44, # The line thickness
      pointer: {
        length: 0.9, # The radius of the inner circle
        strokeWidth: 0.035, # The rotation offset
        color: '#000000' # Fill color
      },
      limitMax: 'true',   # If true, the pointer will not go past the end of the gauge
      colorStart: model.get('colorStart') || '#6FADCF',   # Colors
      colorStop: model.get('colorStop') || model.get('colorStart') || '#6FADCF',    # just experiment with them
      strokeColor: '#E0E0E0',   # to see which ones work best for you
      generateGradient: false
    };

    gauge = new Gauge(@gaugeTarget).setOptions(opts); # create sexy gauge!
    gauge.maxValue = 100; # set max gauge value

    setTimeout (=>
      gauge = new Gauge(@gaugeTarget).setOptions(opts); # create sexy gauge!
      gauge.maxValue = 100; # set max gauge value
      gauge.set(Math.floor(model.get('info')*100) || 0)

      model.on 'change', 'info', (value) =>
        gauge.set(Math.floor(value*100) || 0); # set actual value

    ), 2000