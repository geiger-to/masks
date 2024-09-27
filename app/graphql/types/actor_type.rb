# frozen_string_literal: true

module Types
  class ActorType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :nickname, String
    field :scopes, String
    field :created_at, GraphQL::Types::ISO8601Date, null: false
    field :updated_at, GraphQL::Types::ISO8601Date, null: false
    field :last_login_at, GraphQL::Types::ISO8601Date, null: true
    field :password, Boolean
    field :changed_password_at, GraphQL::Types::ISO8601Date, null: true
    field :added_totp_secret_at, GraphQL::Types::ISO8601Date, null: true
    field :saved_backup_codes_at, GraphQL::Types::ISO8601Date, null: true

    def scopes
      object.scopes.join("\n")
    end

    def password
      object.password_digest.present?
    end
  end
end
