var os = require('os');

exports.free = function(period, cb){
  getCPUUsage(cb, true, period);
}

exports.usage = function(period, cb){
  getCPUUsage(cb, false, period);
}

exports.usageInterval = function(interval, cb){
  getCPUUsage(cb, false, interval);
}

function getCPUInfo(cb){
  var cpus = os.cpus();

  var user = 0;
  var nice = 0;
  var sys = 0;
  var idle = 0;
  var irq = 0;
  var total = 0;

  for(var cpu in cpus){

    user += cpus[cpu].times.user;
    nice += cpus[cpu].times.nice;
    sys += cpus[cpu].times.sys;
    irq += cpus[cpu].times.irq;
    idle += cpus[cpu].times.idle;
  }

  var total = user + nice + sys + idle + irq;

  return {
    'idle': idle,
    'total': total
  };
}

function getCPUUsage(cb, free, period){

  var stats1 = getCPUInfo();
  var startIdle = stats1.idle;
  var startTotal = stats1.total;

  setTimeout(function() {
    var stats2 = getCPUInfo();
    var endIdle = stats2.idle;
    var endTotal = stats2.total;

    var idle 	= endIdle - startIdle;
    var total 	= endTotal - startTotal;
    var perc	= idle / total;

    if(free === true)
      cb( perc );
    else
      cb( (1 - perc) );

  }, period );
}

function getCPUsInfo(cb){
  var cpus = os.cpus();
  var info = [];

  for(var cpu in cpus){
    var user = cpus[cpu].times.user;
    var nice = cpus[cpu].times.nice;
    var sys = cpus[cpu].times.sys;
    var irq = cpus[cpu].times.irq;
    var idle = cpus[cpu].times.idle;

    info[cpu] = {
      idle: cpus[cpu].times.idle,
      total: user + nice + sys + idle + irq
    }
  }

  return info;
}

function getCPUsUsage(cb, free, period){
  var stats1 = getCPUsInfo();

  setTimeout(function() {
    var stats2 = getCPUsInfo();

    var info = [];

    for(var cpu in stats1){
      var startIdle = stats1[cpu].idle;
      var startTotal = stats1[cpu].total;
      var endIdle = stats2[cpu].idle;
      var endTotal = stats2[cpu].total;

      info[cpu] = free ? idle / total : 1 - idle / total;
    }

    cb(info);

  }, period );
}

