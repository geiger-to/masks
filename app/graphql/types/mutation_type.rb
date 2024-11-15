# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :actor, mutation: Mutations::Actor
    field :client, mutation: Mutations::Client
    field :setting, mutation: Mutations::Setting
    field :authenticate, mutation: Mutations::Authenticate
  end
end
