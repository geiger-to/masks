module Masks
  module Authenticators
    class Identifier < Base
      prompt "identifier" do
        !identifier
      end

      event "identifier:add" do
        return unless updates["identifier"]

        session[:identifiers] ||= {}
        session[:identifiers][identifier] = Time.now.utc.iso8601

        auth_session[:identifier] = identifier
      end

      private

      def prepare
        history.identifier = identifier
        history.actor = find_actor if identifier
      end

      def find_actor
        actor =
          if identifier.include?("@") && Masks.installation.emails?
            Masks::Actor.from_login_email(identifier)
          elsif Masks.installation.nicknames?
            Masks::Actor.find_or_initialize_by(nickname: identifier)
          else
            Masks::Actor.new(identifier: identifier)
          end

        if actor.new_record? && !actor.valid?
          warn!("invalid-identifier")

          self.prompt = "identifier"
        end

        actor
      end

      def identifier
        if event?("identifier:add")
          updates["identifier"]
        else
          auth_session[:identifier]
        end
      end
    end
  end
end
