# frozen_string_literal: true

module Types
  class EntryType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :actor, ActorType
    field :client, ClientType
    field :device, DeviceType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def id
      object.public_id
    end
  end
end
