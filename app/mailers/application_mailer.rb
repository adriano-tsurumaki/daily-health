class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("RESEND_FROM_EMAIL", "noreply@dailyhealth.com")
  layout "mailer"
end
