# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :actor, mutation: Mutations::Actor
    field :client, mutation: Mutations::Client
    field :authorize, mutation: Mutations::Authorize
  end
end
