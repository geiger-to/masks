module Masks
  class Installation < ApplicationRecord
    self.table_name = "masks_installations"

    serialize :settings, coder: JSON
    encrypts :settings

    scope :active, -> { where(expired_at: nil) }

    def setting(*names, default: nil)
      setting = settings.dig(*names.map(&:to_s))
      setting || default
    end

    def authorize_delay
      (settings.dig("authorize", "delay")&.to_i || 0)
    end

    def name
      settings["name"]
    end

    def backup_codes
      {
        min: setting("backup_codes", "min", default: 8),
        max: setting("backup_codes", "max", default: 100),
        total: setting("backup_codes", "total", default: 10),
      }
    end

    def passwords
      {
        min: setting("password", "min", default: 8),
        max: setting("password", "max", default: 100),
      }
    end

    def nicknames?
      setting("nickname", "enabled")
    end

    def emails?
      setting("email", "enabled")
    end

    def login_links?
      emails? && setting(:login_link, :enabled)
    end

    def modify!(settings)
      self.settings = self.settings.deep_merge(settings.deep_stringify_keys)
      self.save!
    end

    def settings
      super || {}
    end

    def seed!
      save!
    end

    def public_settings
      ({ name:, passwords: }).merge(settings.slice(*%w[nickname email url]))
    end
  end
end
