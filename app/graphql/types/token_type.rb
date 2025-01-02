# frozen_string_literal: true

module Types
  class TokenType < Types::BaseObject
    field :id, String, null: false
    field :type, String, null: false
    field :secret, String, null: false
    field :nonce, String, null: true
    field :redirect_uri, String, null: false
    field :scopes, [String], null: false
    field :usable, Boolean, null: false
    field :expired, Boolean, null: false
    field :device, DeviceType, null: false
    field :actor, ActorType, null: false
    field :client, ClientType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: false
    field :refreshed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :revoked_at, GraphQL::Types::ISO8601DateTime, null: true

    def usable
      object.usable?
    end

    def expired
      object.expired?
    end

    def id
      object.public_id
    end

    def secret
      object.obfuscated_secret
    end

    def type
      object.public_type
    end

    def scopes
      object.scopes_a
    end
  end
end
