module Masks
  module Authenticators
    class Onboard < Base
      def enabled?
        client&.require_onboarded_actor? && id_session
      end

      prompt "onboard" do
        onboarding?
      end

      event "onboard:confirm" do
        return unless onboarding?

        actor.onboarded!
      end

      event "onboard-email:add" do
        next unless onboarding?

        add_email
      end

      event "onboard-email:delete" do
        return unless onboarding?

        email =
          actor.emails.for_login.find_by(address: updates["email"]) if updates[
          "email"
        ]

        email&.permanently_delete
      end

      event "onboard-email:verify" do
        return unless onboarding?

        reverify_email
      end

      event "onboard-email:verify-code" do
        return unless onboarding?

        verify_code
      end

      event "onboard:profile" do
        return unless onboarding?

        actor.name = updates["name"] if updates["name"]
        if updates["password"] && client.allow_passwords?
          actor.change_password(updates["password"])
        end

        warn! "invalid-actor" unless actor.save
      end

      event "onboard:avatar" do
        return unless onboarding? && history.upload

        actor.avatar.attach(
          io: history.upload,
          filename: history.upload.original_filename,
        )
      end

      def onboarding?
        !authenticating? && !actor.onboarded?
      end
    end
  end
end
