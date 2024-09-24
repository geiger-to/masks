# frozen_string_literal: true

module Types
  class ActorType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :nickname, String
    field :created_at, GraphQL::Types::ISO8601Date, null: false
    field :last_login_at, GraphQL::Types::ISO8601Date, null: true
  end
end
