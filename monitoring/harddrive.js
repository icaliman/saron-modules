// Hard Disk Drive
exports.harddrive = function(callback){

  require('child_process').exec('df -k', function(error, stdout, stderr) {

    var total = 0;
    var used = 0;
    var free = 0;

    var lines = stdout.split("\n");

    var str_disk_info = lines[1].replace( /[\s\n\r]+/g,' ');

    var disk_info = str_disk_info.split(' ');

    total = Math.ceil((disk_info[1] * 1024)/ Math.pow(1024,2));
    used = Math.ceil(disk_info[2] * 1024 / Math.pow(1024,2)) ;
    free = Math.ceil(disk_info[3] * 1024 / Math.pow(1024,2)) ;

    callback(total, free, used);
  });
}