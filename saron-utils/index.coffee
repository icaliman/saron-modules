
class SaronUtils
  getPrimus: ->
    return null unless window?.Primus
    unless @primus
      @primus = new Primus()
#      @primus.open()
    @primus

  destroyPrimus: ->
    @primus && @primus.end() && delete @primus


module.exports = new SaronUtils()