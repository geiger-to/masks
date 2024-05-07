# frozen_string_literal: true

module Masks
  module Rails
    module Identifiers
      class Nickname < Base
        class << self
          def match(value:)
            value = prefix(value)

            return unless self.format.match?(value)

            new(value:, type: self)
          end

          def prefix(value)
            return unless value&.present?

            prefix = Masks.setting('nickname.prefix')

            if !prefix || prefix.blank? || value.start_with?(prefix)
              return value
            end

            "#{prefix}#{value}"
          end

          def format
            prefix = Masks.setting('nickname.prefix')

            if prefix
              /^[#{prefix}]([a-z])([\w\-]+)$/
            else
              /^[a-z][\w\-]+[a-z0-9]$/
            end
          end
        end

        after_initialize :add_prefix

        validates :value,
          format: { with: -> { self.format } },
          length: {
            minimum: -> { Masks.setting('nickname.minimum').to_i },
            maximum: -> { Masks.setting('nickname.maximum').to_i }
          }, if: :value

        private

        def add_prefix
          self.value = value&.present? ? self.class.prefix(value) : nil
        end
      end
    end
  end
end
