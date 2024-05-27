# frozen_string_literal: true

module Masks
  module Identifiers
    class Phone < ::Masks::Identifier
      after_initialize :parse_phone, if: :new_record?

      validates :value, phone: true, if: :value

      def match?
        Phonelib.possible?(value)
      end

      private

      def parse_phone
        return unless value && match?

        self.value = Phonelib.parse(value).full_international
      end
    end
  end
end
