# frozen_string_literal: true

module Mutations
  class Authorize < BaseMutation
    input_object_class Types::AuthorizeInputType

    field :actor, Types::ActorType, null: true
    field :client, Types::ClientType, null: false
    field :nickname, String, null: true
    field :authenticated, Boolean, null: false
    field :authorized, Boolean, null: false
    field :redirect_uri, String, null: true
    field :error, String, null: true

    def resolve(**args)
      history = context[:history]
      client = context.schema.object_from_id(args[:client_id], context)
      actor =
        if args[:nickname]
          Masks::Actor.find_by(nickname: args[:nickname])
        elsif history.actor
          history.actor
        end

      if actor
        if args[:password]
          if actor.authenticate(args[:password])
            history.authenticate(client:, actor:)
          else
            history.denied("invalid credentials", client:, actor:)
          end
        else
          history.identify(client:, actor:)
        end
      elsif args[:nickname] && args[:password]
        history.denied("invalid credentials")
      end

      {
        client: client,
        actor: actor,
        error: history.error,
        nickname: args[:nickname] || history.nickname,
        authenticated: history.authenticated?,
        authorized: history.authorized?(client),
        redirect_uri: history.authorized?(client) ? args[:redirect_uri] : nil,
      }
    end
  end
end
