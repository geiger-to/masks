# frozen_string_literal: true

module Types
  class CodeType < Types::BaseObject
    field :code, String, null: false
    field :nonce, String, null: true
    field :redirect_uri, String, null: false
    field :scopes, [String], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: false

    def code
      object.obfuscated_code
    end
  end
end
