module Masks
  module Authenticators
    class Credential < Base
      prompt "credential" do
        credentials_required?
      end

      event "password:check" do
        next unless id_session && client.allow_passwords?

        password = updates["password"]

        unless actor && password && actor&.authenticate(password)
          self.prompt = "credential"

          next warn! "invalid-credentials"
        end

        authenticated!(client.auth_via_password_expires_at)

        actor_session[:password_entered_at] = Time.now.utc
      end

      private

      def credentials_required?
        history.identifier && authenticating?
      end
    end
  end
end
