module Masks
  class Installation < ApplicationRecord
    self.table_name = "masks_installations"

    serialize :settings, coder: JSON
    encrypts :settings

    scope :active, -> { where(expired_at: nil) }

    def name
      settings[:name]
    end

    def nicknames?
      settings.dig("nickname", "enabled")
    end

    def emails?
      settings.dig("email", "enabled")
    end

    def modify!(settings)
      self.settings = self.settings.deep_merge(settings)
      self.save!
    end

    def settings
      super || {}
    end

    def seed!
      save!
    end

    def public_settings
      ({ name: }).merge(settings.slice(*%w[nickname email url]))
    end
  end
end
