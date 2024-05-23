module Masks
  module Requests
    class Signup < ApplicationModel
      attribute :request
      attribute :tenant
      attribute :profile
      attribute :hint

      def tenant_key
        "masks:#{tenant.version}"
      end

      def actor_key
        "#{tenant_key}:actor_id"
      end

      attr_writer :actor

      def actor
        @actor ||= if request.session[actor_key]
          tenant.actors.find_by(uuid: request.session[actor_key])
        elsif hint
          profile.find_actor(identifier: hint)
        end
      end

      def actor_session
        return unless actor

        request.session["masks:#{actor.session_key}"] ||= {}
      end
    end
  end
end
