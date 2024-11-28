# frozen_string_literal: true

module Types
  class ClientType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :node_id, ID
    field :name, String
    field :type, String
    field :secret, String
    field :logo, String
    field :public_url, String, null: true
    field :redirect_uris, String
    field :response_types, [String]
    field :checks, [String], null: false
    field :lifetime_types, [String], null: false
    field :scopes, GraphQL::Types::JSON, null: false
    field :consent, Boolean

    field :pairwise_salt, String, null: false

    Masks::Client::LIFETIME_COLUMNS.each { |col| field col, String }
    Masks::Client::STRING_COLUMNS.each { |col| field col, String }
    Masks::Client::BOOLEAN_COLUMNS.each { |col| field col, Boolean }

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def id
      object.key
    end

    def node_id
      context.schema.id_from_object(object)
    end

    def type
      object.client_type
    end

    def logo
      if object.logo.attached?
        rails_storage_proxy_url(object.logo.variant(:preview))
      end
    end

    def consent
      !object.auto_consent?
    end

    def lifetime_types
      Masks::Client::LIFETIME_COLUMNS.map { |c| c.to_s.camelize(:lower) }
    end
  end
end
