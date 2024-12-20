module Masks
  module Checks
    class Credentials < Base
      def checked!(with:)
        state.actor_bag["credentials"] = {
          "expires_at" => expires_at("#{with}_factor"),
          "with" => with,
        }
      end

      def checked?
        !Masks.time.expired?(state.actor_bag&.dig("credentials", "expires_at"))
      end
    end
  end
end
