var cpu = require('./cpu');
var memory = require('./memory');

exports.usage = function(period, cb) {
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
  } else if (!cb) return console.err('Monitoring usage: usageInterval([interval,] callback);');

  return setInterval(function() {
    cb({
      cpu: cpu.usage(),
      cpus: cpu.usageCPUs(),
      memory: memory.usage()
    });
  }, interval);
}