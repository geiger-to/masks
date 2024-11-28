# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Auth API
    field :authenticate, mutation: Mutations::Authenticate

    # Admin features
    field :actor, mutation: Mutations::Actor, managers_only: true
    field :client, mutation: Mutations::Client, managers_only: true
    field :install, mutation: Mutations::Installation, managers_only: true
  end
end
