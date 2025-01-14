# frozen_string_literal: true

module Types
  class EntryType < Types::BaseObject
    field :id, String, null: true
    field :prompt, String, null: true
    field :warnings, [String], null: false
    field :error, String, null: true
    field :redirect_uri, String, null: true
    field :scopes, [Types::ScopeType], null: true
    field :actor, Types::ActorType, null: true
    field :login_link, Types::LoginLinkType, null: true
    field :client, Types::ClientType, null: true
    field :extras, CamelizedJSON, null: true
    field :settings, Types::SettingsType, null: true

    bool :settled
    bool :trusted
  end
end
