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
    field :needs_restart, Boolean, null: true
    field :theme, Types::CamelizedJSON, null: false
    field :emails, Types::CamelizedJSON, null: false
    field :nicknames, Types::CamelizedJSON, null: false
    field :passwords, Types::CamelizedJSON, null: false
    field :passkeys, Types::CamelizedJSON, null: false
    field :login_links, Types::CamelizedJSON, null: false
    field :backup_codes, Types::CamelizedJSON, null: false
    field :totp_codes, Types::CamelizedJSON, null: false
    field :phones, Types::CamelizedJSON, null: false
    field :webauthn, Types::CamelizedJSON, null: false
    field :checks, Types::CamelizedJSON, null: false
    field :clients, Types::CamelizedJSON, null: false
    field :integration, Types::CamelizedJSON, null: false
    field :sessions, Types::CamelizedJSON, null: false
    field :devices, Types::CamelizedJSON, null: false
    field :actors, Types::CamelizedJSON, null: false
    field :stats, Types::CamelizedJSON, null: false
    field :recent_clients, [Types::ClientType], null: false
    field :recent_actors, [Types::ActorType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def recent_actors
      Masks::Actor.limit(10).order(created_at: :desc)
    end

    def recent_clients
      Masks::Client.limit(10).order(created_at: :desc)
    end

    def favicon
      rails_storage_proxy_url(object.favicon) if object.favicon.attached?
    end

    def stats
      tokens =
        Masks::AuthorizationCode.count + Masks::AccessToken.count +
          Masks::IdToken.count

      {
        actors: Masks::Actor.count,
        emails: Masks::Email.count,
        phones: Masks::Phone.count,
        clients: Masks::Client.count,
        devices: Masks::Device.count,
        entries: Masks::Entry.count,
        tokens:,
      }
    end
  end
end
