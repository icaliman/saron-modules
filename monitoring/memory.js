var os = require('os');

exports.total = function(){
  return os.totalmem() / ( 1024 * 1024 );
}

exports.free = function(){
  return os.freemem() / os.totalmem();
}

exports.usage = function(){
  return 1 - os.freemem() / os.totalmem();
}