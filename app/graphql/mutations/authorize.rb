# frozen_string_literal: true

module Mutations
  class Authorize < BaseMutation
    input_object_class Types::AuthorizeInputType

    include HistoryHelper

    field :request_id, String, null: true
    field :client, Types::ClientType, null: true
    field :actor, Types::ActorType, null: true
    field :identicon_id, String, null: true
    field :identifier, String, null: true
    field :nickname, String, null: true
    field :avatar, String, null: true
    field :authenticated, Boolean, null: true
    field :successful, Boolean, null: true
    field :settled, Boolean, null: true
    field :redirect_uri, String, null: true
    field :error_message, String, null: true
    field :error_code, String, null: true
    field :prompt, String, null: false
    field :settings, GraphQL::Types::JSON, null: true

    def resolve(**args)
      history = context[:history]
      history.resume!(args[:id], args[:identifier])
      history.authenticate!(args[:password])
      history.authorize!(args[:event])

      result = history_result(history)
      result[:request_id] = SecureRandom.uuid
      result[:identifier] ||= args[:identifier]
      result
    end
  end
end
