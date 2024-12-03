module Masks
  class Installation < ApplicationRecord
    self.table_name = "masks_installations"

    serialize :settings, coder: JSON
    encrypts :settings

    has_one_attached :light_logo
    has_one_attached :dark_logo
    has_one_attached :favicon

    scope :active, -> { where(expired_at: nil) }

    validates :name,
              :clients,
              :backup_codes,
              :passwords,
              :theme,
              :checks,
              :prompts,
              presence: true
    validates :url, presence: true, url: true
    validates :timezone,
              presence: true,
              inclusion: {
                in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name },
              }

    def enabled?(key)
      setting(key, :enabled)
    end

    def favicon_url
      url_helpers.rails_storage_proxy_url(favicon) if favicon.attached?
    end

    def light_logo_url
      url_helpers.rails_storage_proxy_url(light_logo) if light_logo.attached?
    end

    def dark_logo_url
      url_helpers.rails_storage_proxy_url(dark_logo) if dark_logo.attached?
    end

    def setting(*names, default: nil)
      setting = settings.dig(*names.map(&:to_s))
      setting || default
    end

    def authorize_delay
      (settings.dig("authorize", "delay")&.to_i || 0)
    end

    %i[name url timezone region theme storage integration].each do |key|
      define_method key do
        setting(key)
      end
    end

    def checks
      Masks::Checks.names(setting(:checks))
    end

    def client_checks
      Masks::Checks.names(setting(:clients, :checks))
    end

    def prompts
      (setting(:prompts) || []).map(&:constantize)
    end

    def sms_codes
      setting(:sms_codes, default: { enabled: false })
    end

    def sms_codes?
      sms_codes["enabled"]
    end

    def totp_codes
      setting(:totp_codes, default: { enabled: false })
    end

    def passkeys
      setting(:passkeys, default: { enabled: false })
    end

    def webauthn
      setting(:webauthn, default: { enabled: false })
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
        min: setting("passwords", "min", default: 8),
        max: setting("passwords", "max", default: 100),
      }
    end

    def clients
      setting(:clients).merge(
        "checks" => Masks::Checks.names(setting(:clients, :checks)),
      )
    end

    def nicknames
      { enabled: nicknames? }
    end

    def nicknames?
      setting("nicknames", "enabled")
    end

    def emails
      { enabled: emails? }
    end

    def emails?
      setting(:emails, :enabled)
    end

    def login_links
      { enabled: login_links? }
    end

    def login_links?
      emails? && setting(:login_links, :enabled)
    end

    def modify(settings)
      self.settings = self.settings.deep_merge(settings.deep_stringify_keys)
    end

    def modify!(*args)
      modify(*args)
      save!
    end

    def settings
      super || {}
    end

    def env
      @env ||= RecursiveOpenStruct.new(settings)
    end

    def seed!
      save!
    end

    def public_settings
      (
        {
          name:,
          url:,
          light_logo_url:,
          dark_logo_url:,
          favicon_url:,
          theme:,
          timezone:,
          region:,
          emails:,
          nicknames:,
          passwords:,
          passkeys:,
          totp_codes:,
          sms_codes:,
          webauthn:,
          backup_codes:,
          login_links:,
          prompts:,
          checks:,
        }
      ).deep_transform_keys { |k| k.to_s.camelize(:lower) }
    end
  end
end
