# frozen_string_literal: true

module Types
  class DeviceType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :session_id, String
    field :name, String
    field :device_type, String
    field :device_name, String
    field :os_name, String
    field :ip_address, String
    field :user_agent, String

    def id
      object.key
    end
  end
end
