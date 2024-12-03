module Masks
  module Integration
    class TestPhone < BasePhone
      class << self
        def verifications
          @verifications ||= {}
        end
      end

      def notify
        code = SecureRandom.alphanumeric(7)

        self.class.verifications[phone.number] = code

        code
      end

      def verify(code)
        self.class.verifications[phone.number] == code
      end
    end
  end
end
