# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :authorize, mutation: Mutations::Authorize
  end
end
