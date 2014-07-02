nodemailer = require 'nodemailer'
prompt = require 'prompt'

class MailSender
  constructor: ->
    @getMailerOptions (mailerOptions) ->

      @smtpTransport = nodemailer.createTransport 'SMTP', mailerOptions

  send: (options) ->
    @smtpTransport.sendMail options, (error, response) ->
      if error
        console.log "Mail Sender: ", error
      else
        console.log "Message sent: " + response.message

  getMailerOptions: (cb) ->

    if process.env.NODEMAILER_SERVICE and process.env.NODEMAILER_USER and process.env.NODEMAILER_PASS
      mailerOptions =
        service: process.env.NODEMAILER_SERVICE
        auth:
          user: process.env.NODEMAILER_USER
          pass: process.env.NODEMAILER_PASS
    else
      try
        mailerOptions = require './../../config/nodemailer'
      catch
        console.log "MailerOptions file doesn't exists."

      unless mailerOptions?.service
        prompt.start()
        prompt.get
          service:
            message: 'Enter email service'
            required: true
          email:
            message: 'Enter email address'
            required: true
          password:
            message: 'Enter email password'
            required: true
            hidden: true
        , (err, result) ->
          console.log "You writed: ", result
          mailerOptions =
            service: result.service
            auth:
              user: result.email
              pass: result.password
          cb mailerOptions
    cb mailerOptions

module.exports = new MailSender()