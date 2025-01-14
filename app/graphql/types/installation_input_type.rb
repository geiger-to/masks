# frozen_string_literal: true

module Types
  class InstallationInputType < Types::BaseInputObject
    argument :theme, Types::CamelizedJSON, required: false
    argument :nicknames, Types::CamelizedJSON, required: false
    argument :passwords, Types::CamelizedJSON, required: false
    argument :backup_codes, Types::CamelizedJSON, required: false
    argument :clients, Types::CamelizedJSON, required: false
    argument :integration, Types::CamelizedJSON, required: false
    argument :actors, Types::CamelizedJSON, required: false
    argument :devices, Types::CamelizedJSON, required: false
    argument :sessions, Types::CamelizedJSON, required: false
  end
end
