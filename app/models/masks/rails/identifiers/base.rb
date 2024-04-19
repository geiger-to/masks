# frozen_string_literal: true

module Masks
  module Rails
    module Identifiers
      class Base < ApplicationRecord
        self.table_name = "actor_identifiers"

        class << self
          def match(value:)
            return unless value

            Masks.configuration.identifiers.each do |cls|
              if (match = cls.match(value:))
                return match
              end
            end

            nil
          end

          def find_match(value:)
            matched = match(value:)
            matched ? find_by(value: matched.value, type: matched.type) : nil
          end
        end

        after_initialize :generate_sha

        belongs_to :actor, class_name: Masks.configuration.models[:actor]

        validates :value,  presence: true, uniqueness: true
        validates :type, presence: true

        private

        def generate_sha
          self.sha ||= Digest::SHA256.hexdigest(value) if value
        end
      end
    end
  end
end
