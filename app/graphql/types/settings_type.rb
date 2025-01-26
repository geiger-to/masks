# frozen_string_literal: true

module Types
  class SettingsType < Types::BaseObject
    field :name, String, null: true
    field :url, String, null: true
    field :needs_restart, Boolean, null: true
    field :light_logo_url, String, null: true
    field :dark_logo_url, String, null: true
    field :favicon_url, String, null: true
    field :timezone, String, null: true
    field :region, String, null: true
    field :theme, CamelizedJSON, null: true
    field :nicknames, CamelizedJSON, null: true
    field :passwords, CamelizedJSON, null: true
    field :backup_codes, CamelizedJSON, null: true
  end
end
