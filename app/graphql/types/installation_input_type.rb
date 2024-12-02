# frozen_string_literal: true

module Types
  class InstallationInputType < Types::BaseInputObject
    argument :theme, Types::CamelizedJSON, required: false
    argument :emails, GraphQL::Types::JSON, required: false
    argument :nicknames, GraphQL::Types::JSON, required: false
    argument :passwords, GraphQL::Types::JSON, required: false
    argument :passkeys, GraphQL::Types::JSON, required: false
    argument :login_links, GraphQL::Types::JSON, required: false
    argument :backup_codes, GraphQL::Types::JSON, required: false
    argument :totp_codes, GraphQL::Types::JSON, required: false
    argument :sms_codes, GraphQL::Types::JSON, required: false
    argument :webauthn, GraphQL::Types::JSON, required: false
    argument :checks, GraphQL::Types::JSON, required: false
    argument :clients, GraphQL::Types::JSON, required: false
  end
end
