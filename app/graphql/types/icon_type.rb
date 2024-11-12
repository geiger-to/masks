# frozen_string_literal: true

module Types
  class IconType < Types::BaseObject
    field :light, String, null: true
    field :dark, String, null: true
  end
end
