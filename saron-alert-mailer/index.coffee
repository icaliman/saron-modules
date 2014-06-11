events = require 'events'

class SaronMailer extends events.EventEmitter
  init: (store, primus) ->
    console.log 'Saron: Init mailer'

    @store = store
    @mailSender = require './mail-sender'
    @initMonitorAlertMailer()

  initMonitorAlertMailer: ->
    try
      monitorAlerts = require 'saron-monitor-alerts'

      monitorAlerts.on 'cpu-usage-alert', (server) =>
        mail_msg = "On your '#{server.name}' server CPU usage was over #{server.alerts.cpu.value}% for #{server.alerts.cpu.period} seconds."
        @send_mail server, mail_msg

      monitorAlerts.on 'ram-usage-alert', (server) =>
        mail_msg = "On your '#{server.name}' server RAM usage was over #{server.alerts.ram.value}% for #{server.alerts.ram.period} seconds."
        @send_mail server, mail_msg

      monitorAlerts.on 'disk-usage-alert', (server, diskName) =>
        mail_msg = "On your '#{server.name}' server Disk(#{diskName}) usage is over #{server.alerts.disk[diskName].value}%."
        @send_mail server, mail_msg

    catch e
      console.log 'Saron Mailer: "saron-monitor-alerts" module is not installed'

  send_mail: (server, msg) ->
    @getUser server.userID, (user) =>

      mailOptions =
        from: "Saron Monitor <mail@saron.com>"
        to: user.get 'local.email'
        subject: "Alert on '#{server.name}'"
        text: msg
#      html: msg

      @mailSender.send mailOptions

  getUser: (userID, cb) ->
    model = @store.createModel()
    user = model.at "auths.#{userID}"
    user.fetch (err) =>
      return console.log(err) if err
      cb user

module.exports = new SaronMailer()