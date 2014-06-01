var diskspace = require('diskspace');
var drives = require('../../../config/daemon').monitoredDrives;

if (!drives) {
  drives = require('os').platform() == 'win32' ? ['C'] : ['/'];
}

// Hard Disk Drive Usage
exports.usage = function(callback){
  var ds = new DiskUsage(callback);
  ds.check();
};

function DiskUsage(cb) {
  this.drives = drives.slice();

  var usage = [];

  this.check = function() {
    if (this.drives.length == 0) {
      return cb(usage);
    }
    var drive = this.drives.pop();
    this.usage(drive);
  };

  this.usage = function(drive) {
    var _this = this;
    diskspace.check(drive, function(total, free, status) {
      if (status.indexOf('READY') == 0) {
        usage.push(_this.parse(drive, total, free));
      }
      _this.check();
    });
  };

  this.parse = function(drive, total, free) {
    total = parseInt(total);
    free = parseInt(free);

    var used = total - free;

    return {                  // 1024 * 1024 * 1024 = 1073741824
      name: drive,
      total: Math.round(total / 1073741824 * 10) / 10,
      free: Math.round(free / 1073741824 * 10) / 10,
      used: Math.round(used * 100 / total * 100) / 100
    }
  }
}