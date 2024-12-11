module Masks
  module Prompts
    class ResetPassword < Base
      def enabled?
        client.allow_passwords? && auth_bag
      end

      prompt "reset-password" do
        allow_reset?
      end

      event "reset-password" do
        next unless allow_reset?

        actor.password = updates["newPassword"] if updates["newPassword"]

        unless updates["newPassword"] && actor.save
          next warn! "invalid-password"
        end

        warn! "changed-password"

        auth_bag[:reset_password] = false

        self.prompt = "reset-password"
      end

      event "reset-password:skip" do
        next unless allow_reset?

        auth_bag[:reset_password] = false
      end

      private

      def allow_reset?
        authenticated? && auth_bag[:reset_password]
      end
    end
  end
end
