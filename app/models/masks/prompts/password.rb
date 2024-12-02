module Masks
  module Prompts
    class Password < Base
      def enabled?
        client.allow_passwords? && identifier && checking?("credentials")
      end

      event "password:verify" do
        password = updates["password"]

        unless actor && password && actor.authenticate(password)
          self.prompt = "credentials"

          next warn! "invalid-credentials"
        end

        checked!("credentials", with: :password)
      end
    end
  end
end
