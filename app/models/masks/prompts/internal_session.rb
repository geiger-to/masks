module Masks
  module Prompts
    class InternalSession < Base
      around_session always: true do |auth, block|
        block.call

        if auth.approved?
          auth.client_bag["current_actor"] = {
            "key" => auth.actor.key,
            "ver" => auth.actor.version,
            "exp" => client.expires_at(:internal_session),
          }
        end
      end

      def manager
        @manager ||=
          begin
            find_actor(
              client_bag(Masks::Client.manage)&.fetch("current_actor", nil),
            )
          end
      end

      def find_actor(data)
        return unless data

        unless Masks.time.expired?(data["exp"])
          a = Masks::Actor.find_by(key: data["key"])
          a if a&.version == data["ver"]
        end
      end
    end
  end
end
