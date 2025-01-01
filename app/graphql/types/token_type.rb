# frozen_string_literal: true

module Types
  class TokenType < Types::BaseObject
    field :id, String, null: false
    field :type, String, null: false
    field :token, String, null: false
    field :nonce, String, null: false
    field :redirect_uri, String, null: false
    field :scopes, [String], null: false
    field :entry, EntryType, null: false
    field :device, DeviceType, null: false
    field :actor, ActorType, null: false
    field :client, ClientType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: false
    field :refreshed_at, GraphQL::Types::ISO8601DateTime, null: false

    def id
      object.public_id
    end

    def token
      object.obfuscated_token
    end

    def type
      object.public_type
    end
  end
end
