# frozen_string_literal: true

module Types
  class ProviderType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID, null: true
    field :name, String, null: true
    field :type, String, null: true
    field :settings, Types::CamelizedJSON, null: true
    field :callback_uri, String, null: true
    field :disabled, Boolean, null: true
    field :common, Boolean, null: true
    field :setup, Boolean, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :disabled_at, GraphQL::Types::ISO8601DateTime, null: true

    def id
      object.key
    end

    def type
      object.public_type
    end

    def setup
      object.setup?
    end

    def callback_uri
      callback_url(object) if object.persisted?
    end
  end
end
