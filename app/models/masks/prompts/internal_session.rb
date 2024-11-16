module Masks
  module Prompts
    class InternalSession < Base
      around_session always: true do |auth, block|
        block.call

        if auth.approved?
          client_bag[:current_actor] = {
            key: auth.actor.key,
            exp: client.expires_at(:internal_session),
          }
        end
      end

      def current_actor
        @current_actor ||=
          if !Masks.time.expired?(client_bag&.dig(:current_actor, :exp))
            Masks::Actor.find_by(key: client_bag.dig(:current_actor, :key))
          end
      end
    end
  end
end
