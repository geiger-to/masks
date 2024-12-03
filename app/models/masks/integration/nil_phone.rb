module Masks
  module Integration
    class NilPhone < BasePhone
      def notify
        false
      end

      def verify(code)
        false
      end
    end
  end
end
