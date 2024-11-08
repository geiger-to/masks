# frozen_string_literal: true

module Mutations
  class Authorize < BaseMutation
    input_object_class Types::AuthorizeInputType

    include HistoryHelper

    field :request_id, String, null: true
    field :client, Types::ClientType, null: true
    field :actor, Types::ActorType, null: true
    field :login_link, Types::LoginLinkType, null: true
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
    field :warnings, [String], null: false
    field :prompt, String, null: false
    field :settings, GraphQL::Types::JSON, null: true
    field :extras, GraphQL::Types::JSON, null: true

    def resolve(**args)
      delay = Masks.installation.authorize_delay
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      history = context[:history]
      history.authenticate!(**args)

      result = history_result(history)
      result[:request_id] = SecureRandom.uuid
      result[:identifier] ||= args[:identifier]
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      taken = (ending - starting).to_f * 1000
      min_ms = ([delay - taken, 0].max)
      sleep min_ms / 1000 if min_ms.nonzero?
      result
    end
  end
end
