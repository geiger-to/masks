# frozen_string_literal: true

module Masks
  module Identifiers
    class Nickname < ::Masks::Identifier
      after_initialize :add_prefix

      validates :value,
                format: {
                  with: ->(record) { record.format }
                },
                length: {
                  minimum: ->(record) { record.setting("minimum").to_i },
                  maximum: ->(record) { record.setting("maximum").to_i }
                },
                if: :value

      def format
        prefix ? /^[#{prefix}]([a-z])([\w\-]+)$/ : /^[a-z][\w\-]+[a-z0-9]$/
      end

      def match?
        format.match?(value)
      end

      private

      def add_prefix
        self.value = prefixed_value
      end

      def prefixed_value
        return unless value&.present?

        return value if !prefix || prefix.blank? || value.start_with?(prefix)

        "#{prefix}#{value}"
      end

      def prefix
        setting(:prefix)
      end
    end
  end
end
