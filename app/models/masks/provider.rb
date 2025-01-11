# frozen_string_literal: true

module Masks
  class Provider < ApplicationRecord
    include Masks::SettingsColumn

    self.table_name = "masks_providers"

    CLASS_MAP = {
      "Masks::Providers::Github" => "github",
      "Masks::Providers::Google" => "google",
      "Masks::Providers::Facebook" => "facebook",
      "Masks::Providers::Twitter" => "twitter",
      "Masks::Providers::Apple" => "apple",
    }
    TYPE_MAP = CLASS_MAP.invert

    class << self
      def for_client(client)
        includes(:clients).where(
          masks_provider_clients: {
            client_id: client.id,
          },
        ).or(Masks::Provider.common)
      end
    end

    validates :name, presence: true
    validates :key, presence: true, uniqueness: true

    has_many :provider_clients, class_name: "Masks::ProviderClient"
    has_many :clients, class_name: "Masks::Client", through: :provider_clients
    has_many :single_sign_ons, class_name: "Masks::SingleSignOn"

    scope :common, -> { where(common: true) }
    scope :enabled, -> { where(disabled_at: nil) }

    after_initialize :generate_defaults

    generate_key from: :name

    def to_param
      key
    end

    def add_client!(client)
      provider_clients.find_or_create_by!(client:)
    end

    def remove_client!(client)
      provider_clients.find_by(client:).destroy
    end

    def setup?
      setting(:client_id)&.present? && setting(:client_secret)&.present?
    end

    def disable
      self.disabled_at = Time.current
    end

    def enable
      self.disabled_at = nil
    end

    def disabled
      self.disabled_at&.present?
    end

    def omniauth_strategy
      raise NotImplementedError
    end

    def omniauth_args
      [setting(:client_id), setting(:client_secret)]
    end

    def omniauth_opts
      {}
    end

    def public_type
      CLASS_MAP.fetch(self.class.to_s)
    end

    private

    def generate_defaults
      name = self.class.name.split("::").last

      self.name ||= name.humanize
    end
  end
end
