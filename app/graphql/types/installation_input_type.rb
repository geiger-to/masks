# frozen_string_literal: true

module Types
  class InstallationInputType < Types::BaseInputObject
    argument :theme, Types::CamelizedJSON, required: false
    argument :emails, Types::CamelizedJSON, required: false
    argument :nicknames, Types::CamelizedJSON, required: false
    argument :passwords, Types::CamelizedJSON, required: false
    argument :passkeys, Types::CamelizedJSON, required: false
    argument :login_links, Types::CamelizedJSON, required: false
    argument :backup_codes, Types::CamelizedJSON, required: false
    argument :totp_codes, Types::CamelizedJSON, required: false
    argument :phones, Types::CamelizedJSON, required: false
    argument :webauthn, Types::CamelizedJSON, required: false
    argument :checks, Types::CamelizedJSON, required: false
    argument :clients, Types::CamelizedJSON, required: false
    argument :integration, Types::CamelizedJSON, required: false
    argument :lifetimes, Types::CamelizedJSON, required: false
  end
end
