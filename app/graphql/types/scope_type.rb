# frozen_string_literal: true

module Types
  class ScopeType < Types::BaseObject
    field :name, String, null: false
    field :detail, String, null: true
    field :hidden, Boolean, null: true

    def name
      object
    end

    def detail
      Masks.scopes.detail(object)
    end

    def hidden
      Masks.scopes.hidden?(object)
    end
  end
end
