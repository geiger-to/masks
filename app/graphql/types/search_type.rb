# frozen_string_literal: true

module Types
  class SearchType < Types::BaseObject
    field :actors, [ActorType], null: true
    field :clients, [ClientType], null: true
  end
end
