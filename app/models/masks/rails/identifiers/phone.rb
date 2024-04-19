# frozen_string_literal: true

module Masks
  module Rails
    module Identifiers
      class Phone < Base
        class << self
          def match(value:)
            return unless PhoneLib.valid?(value)

            new(value:, type: self)
          end
        end

        after_initialize :parse_phone, if: :new_record?

        validates :value, phone: true, if: :value

        private

        def parse_phone
          return unless value

          self.value = Phonelib.parse(value).full_international
        end
      end
    end
  end
end
