var cpu = require('./cpu');
var memory = require('./memory');

var usage = exports.usage = function(period, cb) {
  if( typeof period == 'function' ) {
    cb = period;
    period = 1000;
  }

  cpu.usage(period, function(infoCPU) {
    cb({
      cpu: infoCPU,
      memory: memory.usage()
    });
  });
}

exports.usageInterval = function(interval, cb) {
  if( typeof interval == 'function' ) {
    cb = interval;
    interval = 1000;
  }


}