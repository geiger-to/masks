# frozen_string_literal: true

module Types
  class AuthType < Types::BaseObject
    field :id, ID
    field :actor, Types::ActorType, null: true
    field :device, Types::DeviceType, null: false
  end
end
