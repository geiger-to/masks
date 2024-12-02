# frozen_string_literal: true

module Types
  class InstallationType < Types::BaseObject
    field :name, String, null: false
    field :url, String, null: false
    field :light_logo_url, String, null: true
    field :dark_logo_url, String, null: true
    field :favicon_url, String, null: true
    field :timezone, String, null: false
    field :region, String, null: false
    field :theme, Types::CamelizedJSON, null: false
    field :emails, Types::CamelizedJSON, null: false
    field :nicknames, Types::CamelizedJSON, null: false
    field :passwords, Types::CamelizedJSON, null: false
    field :passkeys, Types::CamelizedJSON, null: false
    field :login_links, Types::CamelizedJSON, null: false
    field :backup_codes, Types::CamelizedJSON, null: false
    field :totp_codes, Types::CamelizedJSON, null: false
    field :sms_codes, Types::CamelizedJSON, null: false
    field :webauthn, Types::CamelizedJSON, null: false
    field :checks, Types::CamelizedJSON, null: false
    field :clients, Types::CamelizedJSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def favicon
      rails_storage_proxy_url(object.favicon) if object.favicon.attached?
    end
  end
end
