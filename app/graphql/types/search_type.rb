# frozen_string_literal: true

module Types
  class SearchType < Types::BaseObject
    field :actors, [ActorType], null: true
    field :clients, [ClientType], null: true
    field :devices, [DeviceType], null: true
    field :events, [EventType], null: true
    field :prefix, String, null: true
    field :query, String, null: false
  end
end