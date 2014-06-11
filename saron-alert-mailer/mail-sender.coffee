nodemailer = require 'nodemailer'

class MailSender
  constructor: ->
    mailerOptions = require './../../config/nodemailer'

    @smtpTransport = nodemailer.createTransport 'SMTP', mailerOptions

  send: (options) ->
    @smtpTransport.sendMail options, (error, response) ->
      if error
        console.log "Mail Sender: ", error
      else
        console.log "Message sent: " + response.message

module.exports = new MailSender()