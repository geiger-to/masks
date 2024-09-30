# frozen_string_literal: true

module Types
  class TokenType < Types::BaseObject
    field :token, String, null: false
    field :scopes, [String], null: false
    field :code, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: false
    field :refreshed_at, GraphQL::Types::ISO8601DateTime, null: false

    def token
      object.obfuscated_token
    end

    def code
      object.authorization_code.obfuscated_code
    end
  end
end
