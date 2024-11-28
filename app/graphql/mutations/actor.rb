# frozen_string_literal: true

module Mutations
  class Actor < BaseMutation
    input_object_class Types::ActorInputType

    field :actor, Types::ActorType, null: true
    field :errors, [String], null: true

    def resolve(**args)
      actor =
        if args[:signup]
          Masks.signup(args[:identifier])
        else
          Masks.identify(args[:identifier])
        end

      if (args[:signup] && actor.new_record?) ||
           (!args[:signup] && actor.persisted?)
        actor.password = args[:password] if args[:password] && !args[:signup]
        actor.scopes = args[:scopes] if args[:scopes] && !args[:signup]
        actor.save
      end

      { actor:, errors: actor&.errors&.full_messages&.uniq&.slice(0, 1) }
    end
  end
end
