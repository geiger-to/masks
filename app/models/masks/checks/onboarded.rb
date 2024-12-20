module Masks
  module Checks
    class Onboarded < Base
      def checked!(**args)
        state.actor_bag["onboarded"] = true
      end

      def checked?
        state.actor_bag["onboarded"] if state.actor_bag
      end
    end
  end
end
