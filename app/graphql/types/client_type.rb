# frozen_string_literal: true

module Types
  class ClientType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :name, String
    field :type, String
    field :secret, String
    field :logo, String
    field :public_url, String, null: true
    field :redirect_uris, String
    field :response_types, [String]
    field :scopes, String
    field :consent, Boolean
    field :subject_type, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    Masks::Client::LIFETIME_COLUMNS.each { |col| field col, String }
    Masks::Client::STRING_COLUMNS.each { |col| field col, String }
    Masks::Client::BOOLEAN_COLUMNS.each { |col| field col, Boolean }

    def id
      object.key
    end

    def type
      object.client_type
    end

    def logo
      if object.logo.attached?
        rails_storage_proxy_url(object.logo.variant(:preview))
      end
    end
  end
end
