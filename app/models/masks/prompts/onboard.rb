module Masks
  module Prompts
    class Onboard < Base
      checks "onboarded"

      prompt "onboard" do
        next true unless actor.onboarded?

        checked! "onboarded"

        false
      end

      event "onboard:confirm" do
        actor.onboarded!

        checked! "onboarded"
      end

      event "onboard-email:add" do
        add_email
      end

      event "onboard-email:delete" do
        email =
          actor.emails.for_login.find_by(address: updates["email"]) if updates[
          "email"
        ]

        email&.permanently_delete
      end

      event "onboard-email:verify" do
        reverify_email
      end

      event "onboard-email:verify-code" do
        verify_code
      end

      event "onboard:profile" do
        actor.name = updates["name"] if updates["name"]

        if updates["password"] && client.allow_passwords?
          actor.change_password(updates["password"])
        end

        warn! "invalid-actor" unless actor.save
      end

      event "onboard:avatar" do
        next unless auth.upload

        actor.avatar.attach(
          io: auth.upload,
          filename: auth.upload.original_filename,
        )
      end
    end
  end
end
