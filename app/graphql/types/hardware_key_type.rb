# frozen_string_literal: true

module Types
  class HardwareKeyType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :icons, IconType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def id
      object.external_id
    end

    def icons
      Masks::Fido.aaguid_icon(object.aaguid)
    end
  end
end
