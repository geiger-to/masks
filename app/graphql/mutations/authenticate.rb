# frozen_string_literal: true

module Mutations
  class Authenticate < BaseMutation
    input_object_class Types::AuthenticateInputType

    field :id, String, null: true
    field :request_id, String, null: true
    field :client, Types::ClientType, null: true
    field :actor, Types::ActorType, null: true
    field :login_link, Types::LoginLinkType, null: true
    field :identicon_id, String, null: true
    field :identifier, String, null: true
    field :nickname, String, null: true
    field :avatar, String, null: true
    field :settled, Boolean, null: true
    field :redirect_uri, String, null: true
    field :error, String, null: true
    field :warnings, [String], null: false
    field :scopes, [Types::ScopeType], null: true
    field :prompt, String, null: false
    field :settings, GraphQL::Types::JSON, null: true
    field :extras, GraphQL::Types::JSON, null: true

    def resolve(**args)
      Masks.min_runtime(Masks.installation.authorize_delay) do
        auth.update!(**args.merge(resume: context[:resume]))

        result = auth.as_json
        result[:request_id] = SecureRandom.uuid
        result
      end
    end

    def auth
      @auth ||=
        Masks::Auth.new(
          client: context[:client],
          device: context[:device],
          request: context[:request],
        )
    end
  end
end
