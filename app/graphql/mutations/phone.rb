# frozen_string_literal: true

module Mutations
  class Phone < BaseMutation
    input_object_class Types::PhoneInputType

    field :phone, Types::PhoneType, null: true
    field :phones, [Types::PhoneType], null: true
    field :errors, [String], null: true

    def resolve(**args)
      actor = Masks::Actor.find_by(key: args[:actor_id])

      return { errors: ["unknown actor"] } unless actor

      phones = actor.phones
      phone =
        case args[:action]
        when "create"
          phones.build(number: args[:number])
        when "delete"
          p = phones.find_by(number: args[:number])
          p.mark_for_destruction
          p
        end

      if args[:action] == "delete"
        phone&.destroy if phone.valid?
      else
        phone.save
      end

      { phone:, phones:, errors: phone&.errors&.full_messages }
    end
  end
end
