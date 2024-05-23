# frozen_string_literal: true

module Masks
  class Identifier < ApplicationRecord
    self.table_name = "masks_identifiers"

    belongs_to :tenant, class_name: 'Masks::Tenant'
    belongs_to :profile, class_name: 'Masks::Profile', optional: true
    belongs_to :actor, class_name: 'Masks::Actor'

    validates :value, presence: true, uniqueness: true
    validates :type, presence: true

    attribute :key

    def match?
      raise NotImplementedError
    end

    def key
      super || self.class.name.split('::').last.underscore.to_sym
    end

    def verified?
      verified_at && verified_at < Time.current
    end

    def setting(*args, **opts)
      profile ? profile.setting(key, *args, **opts) : tenant.setting(key, *args, **opts)
    end
  end
end
