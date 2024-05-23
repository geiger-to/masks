# frozen_string_literal: true

module Masks
    module Identifiers
      class Email < ::Masks::Identifier
        validates :value, length: { maximum: 256 }, email: true, if: :value

        def match?
          ValidateEmail.valid?(value)
        end
      end
    end
end
