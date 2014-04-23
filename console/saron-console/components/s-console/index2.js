module.exports = Console

function Console() {}

Console.prototype.view = __dirname;

Console.prototype.create = function(model, dom) {
//  TODO: save commands list to localStorage
  model.setNull('commands', []);
};

Console.prototype.newCommand = function() {
  var model = this.model;
  var command = model.del('command');
  var index = model.push('commands', {text: command, pwd: model.get('pwd')});

  if (!command) return;

  model.set("waitingResult", true);

  _this = this;
  this.emit('newCommand', command, function(err, result) {
    model.set("commands." + (index - 1) + ".result", result);
    if (err) {
      model.set("commands." + (index - 1) + ".error", err);
    }
    model.set("waitingResult", false);
    setTimeout(function() {
      _this.selectConsoleInput();
    }, 0);
  });
};

Console.prototype.stringify = function(e) {
  if (typeof e === 'object') {
    return JSON.stringify(e);
  }
  return e && e + '';
};

Console.prototype.selectConsoleInput = function() {
  this.consoleInput.focus();
};