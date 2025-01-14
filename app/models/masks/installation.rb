module Masks
  class Installation < ApplicationRecord
    include SettingsColumn

    RECONFIGURATION_KEYS = [
      %w[sentry dsn],
      %w[newrelic license_key],
      %w[newrelic app],
      %w[sessions lifetime],
      %w[devices lifetime],
    ]

    self.table_name = "masks_installations"

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

    def duration(*keys, **args)
      Masks.time.duration(setting(*keys, **args))
    end

    def enabled?(key)
      setting(key, :enabled)
    end

    def manager?
      (env.manager.nickname&.present? || env.manager.email&.present?) &&
        env.manager.password&.present?
    end

    def favicon_url
      return url_helpers.rails_storage_proxy_url(favicon) if favicon.attached?

      setting(:theme, :favicon_url)
    end

    def light_logo_url
      if light_logo.attached?
        return url_helpers.rails_storage_proxy_url(light_logo)
      end

      setting(:theme, :light_logo_url)
    end

    def dark_logo_url
      if dark_logo.attached?
        return url_helpers.rails_storage_proxy_url(dark_logo)
      end

      setting(:theme, :dark_logo_url)
    end

    def authorize_delay
      (settings.dig("authorize", "delay")&.to_i || 0)
    end

    def provider_types
      setting(:providers, default: Masks::Provider::CLASS_MAP.keys).map do |cls|
        cls.constantize.new
      end
    end

    %i[
      name
      url
      timezone
      region
      theme
      storage
      integration
      sessions
      devices
      actors
    ].each do |key|
      define_method key do
        setting(key)
      end
    end

    def checks
      Masks::Checks.names(setting(:checks))
    end

    def prompts
      (setting(:prompts) || [])
        .map do |cls|
          cls&.constantize
        rescue NameError
          nil
        end
        .compact
    end

    def backup_codes
      {
        min_chars: setting("backup_codes", "min_chars", default: 8),
        max_chars: setting("backup_codes", "max_chars", default: 100),
        total: setting("backup_codes", "total", default: 10),
      }
    end

    def nicknames
      {
        min_chars: setting("nicknames", "min_chars", default: 4),
        max_chars: setting("nicknames", "max_chars", default: 20),
        format:
          setting(
            "nicknames",
            "format",
            default: '/\A[a-zA-Z][a-zA-Z0-9\-]+\z/',
          ),
      }
    end

    def passwords
      {
        min_chars: setting("passwords", "min_chars", default: 8),
        max_chars: setting("passwords", "max_chars", default: 100),
        cooldown:
          setting("passwords", "change_cooldown", default: "15 minutes"),
      }
    end

    def clients
      setting(:clients, default: {}).merge(
        "checks" => Masks::Checks.names(setting(:clients, :checks)),
      )
    end

    def emails
      setting(:emails, default: {}).merge(
        max_for_login: Masks.setting(:emails, :max_for_login, default: 5),
      )
    end

    def modify(updates)
      return unless updates

      updates = updates.deep_stringify_keys
      reconfigured =
        RECONFIGURATION_KEYS.any? do |key|
          exists = updates.dig(*key.slice(0...-1))&.key?(key.last)

          next unless exists

          current = setting(*key)
          updated = updates.dig(*key)
          current != updated
        end

      merge_settings(updates)

      self.reconfigured_at = Time.current if reconfigured
    end

    def modify!(*args)
      modify(*args)
      save!
    end

    def env
      @env ||= RecursiveOpenStruct.new(settings)
    end

    def seed!
      save!

      seeds.import!
    end

    def needs_restart
      !!reconfigured_at&.present?
    end

    def public_settings
      (
        {
          name:,
          url:,
          needs_restart:,
          light_logo_url:,
          dark_logo_url:,
          favicon_url:,
          theme:,
          timezone:,
          region:,
          nicknames:,
          passwords:,
          backup_codes:,
        }
      )
    end
  end
end
