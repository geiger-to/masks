module Masks
  # Preview all emails at http://localhost:3000/rails/mailers/actor_mailer
  class ActorMailerPreview < ActionMailer::Preview
    def verify_email
      ActorMailer.with(email: Masks::Rails::Email.last).verify_email
    end

    def recover_credentials
      ActorMailer.with(recovery: Masks::Rails::Recovery.last.id).recover_credentials
    end
  end
end
