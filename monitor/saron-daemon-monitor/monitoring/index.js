var cpu = require('./cpu');
var memory = require('./memory');
var disk = require('./disk');

exports.usage = function(period, cb) {
  if( typeof period == 'function' ) {
    cb = period;
    period = 1000;
  }

  disk.usage(function(diskUsage) {
    cpu.usage(period, function(infoCPU) {
      cb({
        cpu: infoCPU,
        memory: memory.usage(),
        disk: diskUsage
      });
    });
  });
}

exports.usageInterval = function(interval, cb) {
  if( typeof interval == 'function' ) {
    cb = interval;
    interval = 1000;
  } else if (!cb) return console.err('Monitoring usage: usageInterval([interval,] callback);');

  return setInterval(function() {
    disk.usage(function(diskUsage) {
      cb({
        cpu: cpu.usage(),
        cpus: cpu.usageCPUs(),
        memory: memory.usage(),
        disk: diskUsage
      });
    });
  }, interval);
}