module Masks
  module Authenticators
    class SecondFactor < Base
      def enabled?
        client.require_second_factor? || actor&.second_factor?
      end

      prompt "second-factor" do
        expired_second_factor?
      end

      private

      def expired_second_factor?
        !authenticating? && !id_session&.dig(:second_factor)
      end
    end
  end
end
