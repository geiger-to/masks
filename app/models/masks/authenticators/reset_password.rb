module Masks
  module Authenticators
    class ResetPassword < Base
      def enabled?
        client.allow_passwords? && id_session
      end

      prompt "reset-password" do
        !authenticating? && id_session[:reset_password]
      end

      event "reset-password" do
        actor.password = updates["newPassword"] if updates["newPassword"]

        unless updates["newPassword"] && actor.save
          self.prompt = "reset-password"

          next warn! "invalid-password"
        end

        id_session[:reset_password] = false
      end

      event "reset-password:skip" do
        id_session[:reset_password] = false
      end
    end
  end
end
