class ApplicationMailer < ActionMailer::Base
  default from: -> { Masks.setting(:emails, :from) },
          reply_to: -> { Masks.setting(:emails, :reply_to) }

  layout "mailer"
end
