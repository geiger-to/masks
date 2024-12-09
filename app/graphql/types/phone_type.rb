# frozen_string_literal: true

module Types
  class PhoneType < Types::BaseObject
    field :number, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :verified_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
