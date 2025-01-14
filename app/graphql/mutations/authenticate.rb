# frozen_string_literal: true

module Mutations
  class Authenticate < BaseMutation
    input_object_class Types::AuthenticateInputType

    field :entry, Types::EntryType, null: false

    def resolve(**args)
      entry =
        if context[:entry]
          context[:entry]
        else
          Masks::Entries::Authentication.new(
            session: context[:session],
            params: args,
          )
        end

      { entry: }
    end
  end
end
