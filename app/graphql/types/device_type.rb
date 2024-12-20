# frozen_string_literal: true

module Types
  class DeviceType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :name, String
    field :type, String
    field :os, String
    field :ip, String
    field :user_agent, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def id
      object.public_id
    end

    def type
      object.device_type
    end

    def os
      object.os_name
    end

    def ip
      object.ip_address
    end
  end
end
