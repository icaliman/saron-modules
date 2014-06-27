nodemailer = require 'nodemailer'

class MailSender
  constructor: ->
    if process.env.NODEMAILER_SERVICE and process.env.NODEMAILER_USER and process.env.NODEMAILER_PASS
      mailerOptions =
        service: process.env.NODEMAILER_SERVICE
        auth:
          user: process.env.NODEMAILER_USER
          pass: process.env.NODEMAILER_PASS
    else
      mailerOptions = require './../../config/nodemailer'

    @smtpTransport = nodemailer.createTransport 'SMTP', mailerOptions

  send: (options) ->
    @smtpTransport.sendMail options, (error, response) ->
      if error
        console.log "Mail Sender: ", error
      else
        console.log "Message sent: " + response.message

module.exports = new MailSender()