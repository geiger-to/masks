module Masks
  module Prompts
    class ResetPassword
      include Masks::Prompt

      KEY = "reset-password"

      match { client.allow_passwords? && trusted? && allow_reset? }

      event "password:reset" do
        actor.password = updates["reset"] if updates["reset"]

        next warn! "invalid-password" unless updates["reset"] && actor.save

        warn! "changed-password"

        session.bag(:entries)[KEY] = false

        self.prompt = "reset-password"
      end

      event "password:skip-reset" do
        next unless allow_reset?

        session.bag(:entries)[KEY] = false
      end

      event "password:skip" do
        next unless allow_reset?

        sibling(:profile).requested! if updates["profile"]

        session.bag(:entries)[KEY] = false
      end

      event "password:skip" do
        next unless allow_reset?

        session.bag(:entries)[KEY] = false
      end

      prompt "reset-password" do
        allow_reset?
      end

      def requested!
        session.bag(:entries)[KEY] = true
      end

      private

      def allow_reset?
        session.bag(:entries)[KEY]
      end
    end
  end
end
