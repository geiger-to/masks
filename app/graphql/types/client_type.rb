# frozen_string_literal: true

module Types
  class ClientType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :node_id, ID
    field :name, String
    field :type, String
    field :secret, String
    field :logo, String
    field :public_url, String, null: true
    field :redirect_uris, String
    field :grant_types, [String]
    field :response_types, [String]
    field :providers, [ProviderType]
    field :checks, [String], null: false
    field :lifetime_types, [String], null: false
    field :scopes, GraphQL::Types::JSON, null: false
    field :consent, Boolean

    field :stats, CamelizedJSON, null: false

    bool :second_factor, prefix: "allow"

    Masks::Client.settings.each { |key, type| field key, type }

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def id
      object.key
    end

    def node_id
      context.schema.id_from_object(object)
    end

    def type
      object.client_type
    end

    def logo
      if object.logo.attached?
        rails_storage_proxy_url(object.logo.variant(:preview))
      end
    end

    def consent
      !object.auto_consent?
    end

    def lifetime_types
      Masks::Client::LIFETIME_SETTINGS.map { |c| c.to_s.camelize(:lower) }
    end

    def stats
      { tokens: object.tokens.count, actors: object.actors.count }
    end

    def providers
      object.providers
    end
  end
end
