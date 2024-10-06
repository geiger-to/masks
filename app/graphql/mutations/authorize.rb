# frozen_string_literal: true

module Mutations
  class Authorize < BaseMutation
    input_object_class Types::AuthorizeInputType

    field :client, Types::ClientType, null: true
    field :nickname, String, null: true
    field :authenticated, Boolean, null: true
    field :authorized, Boolean, null: true
    field :successful, Boolean, null: true
    field :redirect_uri, String, null: true
    field :error_message, String, null: true
    field :error_code, String, null: true
    field :required_scopes, [String], null: true

    def resolve(**args)
      history = context[:history]
      history.actor =
        Masks::Actor.find_or_initialize_by(nickname: args[:nickname]) if args[
        :nickname
      ]
      history.resume!(args[:id])
      history.authenticate!(args[:password]) if args[:password]
      history.authorize!(**args.slice(:approve, :deny))

      {
        client: history.client,
        error_code: history.error,
        error_message: t(history.error),
        nickname: history.nickname || args[:nickname],
        authenticated: history.authenticated?,
        authorized: history.authorized?,
        successful: history.successful?,
        redirect_uri: history.redirect_uri,
        required_scopes: history.required_scopes,
      }
    rescue Rack::OAuth2::Server::Authorize::BadRequest => e
      {
        client: history.client,
        error_code: e.error,
        error_message: e.message,
        redirect_uri: e.redirect_uri,
      }
    end
  end
end
