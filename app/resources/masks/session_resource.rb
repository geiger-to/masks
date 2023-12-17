module Masks
  class SessionResource
    include Alba::Resource

    attributes :id, :ip_address, :user_agent, :fingerprint, :scopes

    attribute :authorized do |session|
      session.passed?
    end

    attribute :actor do |session|
      ActorResource.new(session.actor).to_h
    end
  end
end
