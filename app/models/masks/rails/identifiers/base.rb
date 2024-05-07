# frozen_string_literal: true

module Masks
  module Rails
    module Identifiers
      class Base < ApplicationRecord
        self.table_name = "actor_identifiers"

        class << self
          def find_match(value:)
            matched = Masks.configuration.identifier(key: nil, value:)
            matched ? find_by(value: matched.value, type: matched.type) : nil
          end
        end

        belongs_to :actor, class_name: Masks.configuration.models[:actor]

        validates :value,  presence: true, uniqueness: true
        validates :type, presence: true

        attribute :key

        def key
          super || self.class.name.split('::').last.underscore.to_sym
        end

        def verified?
          verified_at && verified_at < Time.current
        end
      end
    end
  end
end
