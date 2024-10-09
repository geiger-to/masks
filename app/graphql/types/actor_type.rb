# frozen_string_literal: true

module Types
  class ActorType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :nickname, String
    field :scopes, String
    field :avatar, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :last_login_at, GraphQL::Types::ISO8601DateTime, null: true
    field :password, Boolean
    field :changed_password_at, GraphQL::Types::ISO8601DateTime, null: true
    field :added_totp_secret_at, GraphQL::Types::ISO8601DateTime, null: true
    field :saved_backup_codes_at, GraphQL::Types::ISO8601DateTime, null: true

    def id
      object.key
    end

    def avatar
      if object.avatar.attached?
        rails_storage_proxy_url(object.avatar.variant(:preview))
      end
    end

    def scopes
      object.scopes
    end

    def password
      object.password_digest.present?
    end
  end
end
