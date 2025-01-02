# frozen_string_literal: true

module Mutations
  class Token < BaseMutation
    input_object_class Types::TokenInputType

    field :token, Types::TokenType, null: true
    field :errors, [String], null: true

    TYPES = {
      "access-token" => "Masks::AccessToken",
      "client-token" => "Masks::ClientToken",
    }

    def resolve(**args)
      token = (Masks::Token.find_by(key: args[:id]) if args[:id])

      token&.revoked(args[:revoked]) if args.key?(:revoked)

      token&.save

      { token:, errors: token&.errors&.full_messages&.uniq }
    end
  end
end
