module Masks
  module Checks
    class SecondFactor < Base
      def checked!(with:)
        state.actor_bag[:second_factor] = {
          expires_at: expires_at("second_factor_#{with}"),
          with:,
        }
      end

      def checked?
        !Masks.time.expired?(state.actor_bag&.dig(:second_factor, :expires_at))
      end
    end
  end
end
