# frozen_string_literal: true

module Mutations
  class Client < BaseMutation
    input_object_class Types::ClientInputType

    field :client, Types::ClientType, null: false
    field :errors, [String], null: true

    def visible?(context)
      context[:authorization]&.masks_manager?
    end

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
      client.type = args[:type] if args[:type]
      client.redirect_uris = args[:redirect_uris].split("\n") if args[
        :redirect_uris
      ]
      client.scopes_text = args[:scopes] if args[:scopes]
      client.regenerate_secret if args[:rotate_secret]
      client.save

      { client:, errors: client.errors.full_messages }
    end
  end
end
