class ApplicationMailer < ActionMailer::Base
  default from: Fideback::MailerSettings.mailer_sender
  layout "mailer"
end
