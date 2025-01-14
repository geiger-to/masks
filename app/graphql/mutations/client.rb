# frozen_string_literal: true

module Mutations
  class Client < BaseMutation
    input_object_class Types::ClientInputType

    field :client, Types::ClientType, null: false
    field :errors, [String], null: true

    def resolve(**args)
      client =
        (
          if args[:id]
            Masks::Client.find_or_initialize_by(key: args[:id])
          else
            Masks::Client.new
          end
        )

      client.name = args[:name] if args[:name]
      client.secret = args[:secret] if args[:secret]
      client.client_type = args[:type] if args[:type]
      client.redirect_uris = args[:redirect_uris] if args[:redirect_uris]
      client.pairwise_salt = args[:pairwise_salt] if args[:pairwise_salt]
      client.scopes = args[:scopes] if args[:scopes]
      client.merge_settings(args)
      client.save

      { client:, errors: client.errors.full_messages }
    end
  end
end
