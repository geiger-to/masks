# frozen_string_literal: true

module Mutations
  class Actor < BaseMutation
    input_object_class Types::ActorInputType

    field :actor, Types::ActorType, null: true
    field :errors, [String], null: true

    FIELDS = %i[name nickname scopes]

    def resolve(**args)
      actor =
        if args[:signup]
          Masks.signup(args[:identifier])
        else
          Masks::Actor.find_by(key: args[:id])
        end

      if !args[:signup] && actor
        FIELDS.each do |field|
          actor.assign_attributes(field => args[field]) if args[field]
        end
      end

      actor.reset_backup_codes if args[:reset_backup_codes]

      unless args[:signup]
        if args[:password]
          actor.change_password(args[:password])
        elsif args[:reset_password]
          actor.reset_password
        end
      end

      actor&.save

      { actor:, errors: actor&.errors&.full_messages&.uniq }
    end
  end
end
