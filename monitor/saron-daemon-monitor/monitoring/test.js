var cpu = require('./cpu');
var memory = require('./memory')
var m = require('./');

m.usageInterval(1000, function(info) {
  console.log(info);
});

//setTimeout(function() {
//setInterval(function() {
//  console.log(''+cpu.usage());
//  console.log(''+cpu.usageCPUs());
//}, 2000);
