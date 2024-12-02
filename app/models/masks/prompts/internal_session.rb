module Masks
  module Prompts
    class InternalSession < Base
      around_session always: true do |auth, block|
        block.call

        if auth.approved?
          rails_session[:current_actor] = client_bag[:current_actor] = {
            key: auth.actor.key,
            exp: client.expires_at(:internal_session),
          }
        end
      end

      def current_actor
        @current_actor ||=
          begin
            bag = client_bag || rails_session

            unless Masks.time.expired?(bag&.dig(:current_actor, :exp))
              Masks::Actor.find_by(key: bag.dig(:current_actor, :key))
            end
          end
      end
    end
  end
end
