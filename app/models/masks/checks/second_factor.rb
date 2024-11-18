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
        !state.actor&.review_second_factor? && state.actor&.second_factor? &&
          !Masks.time.expired?(
            state.actor_bag&.dig(:second_factor, :expires_at),
          )
      end
    end
  end
end
