# frozen_string_literal: true

module Types
  class ClientType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :name, String
    field :client_type, String
  end
end
