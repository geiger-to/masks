# frozen_string_literal: true

module Types
  class ActorType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID
    field :node_id, ID
    field :name, String, null: true
    field :nickname, String
    field :identifier, String, null: true
    field :identifier_type, String, null: true
    field :login_email, String, null: true
    field :login_emails, [EmailType], null: true
    field :identicon_id, String
    field :scopes, String
    field :avatar, String, null: true
    field :avatar_created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :last_login_at, GraphQL::Types::ISO8601DateTime, null: true
    field :password, Boolean
    field :password_changeable, Boolean
    field :password_changed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :added_totp_secret_at, GraphQL::Types::ISO8601DateTime, null: true
    field :saved_backup_codes_at, GraphQL::Types::ISO8601DateTime, null: true
    field :second_factor, Boolean
    field :hardware_keys, [HardwareKeyType], null: true
    field :otp_secrets, [OtpSecretType], null: true
    field :phones, [PhoneType], null: true
    field :remaining_backup_codes, Integer, null: true
    field :second_factors, [Types::SecondFactorType], null: false
    field :stats, Types::CamelizedJSON, null: false

    def id
      object.key
    end

    def node_id
      context.schema.id_from_object(object)
    end

    def login_email
      object.login_email&.address
    end

    def login_emails
      object.emails.for_login
    end

    def avatar
      object.avatar_url
    end

    def scopes
      object.scopes
    end

    def password
      object.password_digest.present?
    end

    def password_changeable
      object.password_changeable?
    end

    def second_factor
      object.second_factor?
    end

    def remaining_backup_codes
      object.backup_codes&.length
    end

    def stats
      return {} unless object.persisted?

      {
        entries: object.entries.count,
        devices: object.devices.count,
        clients: object.clients.count,
      }
    end
  end
end
