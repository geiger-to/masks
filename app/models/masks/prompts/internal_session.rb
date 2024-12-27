module Masks
  module Prompts
    class InternalSession < Base
      around_session always: true do |auth, block|
        block.call

        if auth.approved?
          auth.client_bag["current_actor"] = {
            "key" => auth.actor.key,
            "exp" => client.expires_at(:internal_session),
          }
        end
      end

      def manager
        @manager ||=
          find_actor(
            client_bag(Masks::Client.manage)&.fetch("current_actor", nil),
          )
      end

      def find_actor(data)
        return unless data

        unless Masks.time.expired?(data["exp"])
          Masks::Actor.find_by(key: data["key"])
        end
      end
    end
  end
end
