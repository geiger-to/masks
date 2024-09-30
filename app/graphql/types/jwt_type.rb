# frozen_string_literal: true

module Types
  class JwtType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
