module Masks
  module Checks
    class ClientConsent < Base
      def checked!(**args)
        state.auth_bag[:client_consent] = args.slice(:approved, :denied)
      end

      def checked?
        state.auth_bag[:client_consent] if state.auth_bag
      end

      def approved?
        checked? && state.auth_bag&.dig(:client_consent, :approved)
      end

      def denied?
        checked? && state.auth_bag&.dig(:client_consent, :denied)
      end
    end
  end
end
