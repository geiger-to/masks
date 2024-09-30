# frozen_string_literal: true

module Mutations
  class Actor < BaseMutation
    input_object_class Types::ActorInputType

    field :actor, Types::ActorType, null: true
    field :errors, [String], null: true

    def visible?(context)
      context[:authorization]&.masks_manager?
    end

    def resolve(**args)
      actor =
        if args[:signup]
          Masks::Actor.new(nickname: args[:nickname]) if args[:signup]
        else
          Masks::Actor.find_by(nickname: args[:nickname])
        end

      actor.password = args[:password] if args[:password]
      actor.scopes_text = args[:scopes] if args[:scopes]
      actor.save if actor

      { actor:, errors: actor&.errors&.full_messages }
    end
  end
end
