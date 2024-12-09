# frozen_string_literal: true

module Mutations
  class Email < BaseMutation
    input_object_class Types::EmailInputType

    field :email, Types::EmailType, null: true
    field :emails, [Types::EmailType], null: true
    field :errors, [String], null: true

    def resolve(**args)
      actor = Masks::Actor.find_by(key: args[:actor_id])

      return { errors: ["unknown actor"] } unless actor

      emails = actor.login_emails
      email =
        case args[:action]
        when "create"
          emails.build(address: args[:address]).for_login
        when "delete"
          e = emails.find_by(address: args[:address])
          e.mark_for_destruction
          e
        when "verify"
          emails.find_by(address: args[:address]).tap { |e| e.verify }
        when "unverify"
          emails.find_by(address: args[:address]).tap { |e| e.unverify }
        end

      if args[:action] == "delete"
        email&.destroy if email.valid?
      else
        email.save
      end

      { email:, emails:, errors: email&.errors&.full_messages }
    end
  end
end
