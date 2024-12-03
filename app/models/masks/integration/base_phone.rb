module Masks
  module Integration
    class BasePhone
      attr_reader :phone

      def initialize(phone)
        @phone = phone
      end

      def notify
        raise NotImplementedError
      end

      def verify(code)
        raise NotImplementedError
      end
    end
  end
end
