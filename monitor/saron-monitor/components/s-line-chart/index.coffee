
module.exports = class SLineChart
  view: __dirname

#  This is called on the server and in the browser
#  init: (model) ->
#    @server = model.at 'server'

#  This is called only in the browser
  create: (model) ->
    @can = @chartTarget
    @ctx = @can.getContext "2d"

    @maxVal = model.get('max-val') || 100
    @minVal = model.get('min-val') || 0
    @numMax = model.get('num-max') || 60
    @yScalar = @can.height / (@maxVal - @minVal)
    @xScalar = @can.width / @numMax
    @rows = @maxVal / 10 - 1
    @cols = @numMax / 10
    @xScalarGrid = @can.width / @cols
    @yScalarGrid = @can.height / (@rows + 1)
    @gridLeftFloat = 0

    model.setNull 'data', []
    @redraw()

    model.on 'insert', 'data', () =>
      console.log model.get 'data'
      @gridLeftFloat = (@gridLeftFloat + 1) % 10
      @redraw()


  redraw: () ->
    data = @model.get 'data'
    num = data.length

    @clear()
    @drawBorder()
    @drawGrid()

    i = Math.max 0, num - @numMax - 1
    x = @can.width - @xScalar * Math.min(num, @numMax + 1)

    @ctx.strokeStyle="rgba(128, 128, 255, 1)"
    @ctx.fillStyle = "rgba(128, 128, 255, 0.1)"
    @ctx.lineWidth = 1.2
    @ctx.beginPath()
    @ctx.moveTo x, @can.height
    while i < num
      x += @xScalar
      y = @can.height - data[i]*@maxVal*@yScalar
      @ctx.lineTo x, y
      i++
    @ctx.lineTo @can.width, @can.height
    @ctx.closePath()
    @ctx.stroke()
    @ctx.fill()

  clear: ->
    @ctx.clearRect(0, 0, @can.width, @can.height);

  drawGrid: () ->
    @ctx.strokeStyle = "rgba(128, 128, 255, 0.5)"
    @ctx.lineWidth = 0.5
    @ctx.beginPath()
    for i in [1..@rows]
      y = i * @yScalarGrid
      @ctx.moveTo(0, y)
      @ctx.lineTo(@can.width, y)
    for i in [1..@cols]
      x = i * @xScalarGrid - @gridLeftFloat * @xScalar
      @ctx.moveTo(x, 0)
      @ctx.lineTo(x, @can.height)
    @ctx.stroke()

  drawBorder: () ->
    @ctx.strokeStyle="rgba(128, 128, 255, 1)"
    @ctx.lineWidth = 1
    @ctx.beginPath()
    @ctx.moveTo(0, 0)
    @ctx.lineTo(@can.width, 0)
    @ctx.lineTo(@can.width, @can.height)
    @ctx.lineTo(0, @can.height)
    @ctx.closePath()
    @ctx.stroke()