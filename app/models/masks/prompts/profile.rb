module Masks
  module Prompts
    class Profile
      include Masks::Prompt

      MARKER = "visit-profile"

      match { trusted? && client.allow_profiles? }

      prompt "profile" do
        if onboarding_required?
          extras(onboarding_required: true)
        else
          session.bag(:entries)[MARKER] ||
            session.bag(:entries).dig(:params, :prompt)&.presence
        end
      end

      event "profile:verify" do
        actor.onboarded!

        checked! "profile"
      end

      event "avatar:upload" do
        next unless auth.upload

        actor.avatar.attach(
          io: auth.upload,
          filename: auth.upload.original_filename,
        )
      end

      event "profile:update" do
        actor.name = updates["name"] if updates["name"]

        warn! "invalid-actor" unless actor.save
      end

      def requested!
        session.bag(:entries)[MARKER] = true
      end

      private

      def onboarding_required?
        return true unless actor.onboarded?
        return false unless client.onboarding_expires_in

        onboard_at =
          actor.onboarded_at + Masks.time.duration(client.onboarding_expires_in)

        Time.current > onboard_at
      end
    end
  end
end
