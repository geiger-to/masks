# frozen_string_literal: true

module Masks
  class SessionResource
    include Alba::Resource

    attributes :id, :ip_address, :user_agent, :fingerprint, :scopes

    attribute :authorized, &:passed?

    attribute :actor do |session|
      ActorResource.new(session.actor).to_h if session.actor
    end
  end
end
