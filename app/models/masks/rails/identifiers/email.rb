# frozen_string_literal: true

module Masks
  module Rails
    module Identifiers
      class Email < Base
        class << self
          def match(value:)
            return unless ValidateEmail.valid?(value)

            new(value:, type: self)
          end
        end

        validates :value, length: { maximum: 256 }, email: true, if: :value
      end
    end
  end
end
