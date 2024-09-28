# frozen_string_literal: true

module Types
  class EventType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :name, String
    field :session_id, String
    field :client_id, String
    field :actor_id, String
    field :created_at, GraphQL::Types::ISO8601Date, null: false
    field :device, Types::DeviceType

    def name
      object.key
    end

    def actor_id
      object.actor.nickname
    end

    def client_id
      object.client.key
    end
  end
end
