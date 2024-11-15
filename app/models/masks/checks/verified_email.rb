module Masks
  module Checks
    class VerifiedEmail < Base
      def checked!
        state.auth_bag[:verified_email] = true
      end

      def checked?
        state.auth_bag[:verified_email] if state.auth_bag
      end
    end
  end
end
