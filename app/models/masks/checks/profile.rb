module Masks
  module Checks
    class Profile < Base
      def checked!(**args)
        state.attempt_bag["profile"] = true
      end

      def checked?
        state.attempt_bag["profile"] if state.attempt_bag
      end
    end
  end
end
