# frozen_string_literal: true

module Types
  class ClientType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :name, String
    field :type, String
    field :secret, String
    field :redirect_uris, [String]
    field :response_types, [String]
    field :scopes, [String]
    field :consent, Boolean
    field :subject_type, String
    field :created_at, GraphQL::Types::ISO8601Date, null: false
    field :updated_at, GraphQL::Types::ISO8601Date, null: false
    field :code_expires_in, String
    field :id_token_expires_in, String
    field :access_token_expires_in, String
    field :refresh_expires_in, String

    def id
      object.key
    end

    def type
      object.client_type
    end
  end
end
