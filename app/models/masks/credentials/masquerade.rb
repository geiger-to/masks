# frozen_string_literal: true

module Masks
  module Credentials
    # Checks for an :actor to masquerade as.
    class Masquerade < Masks::Credential
      checks :actor

      def lookup
        return if session.actor

        value = session.data[:as]

        @loaded =
          case value
          when Masks::ANON
            Actors::Anonymous.new(session:) if session.mask&.allow_anonymous?
          when session.mask.actor_scope
            value
          else
            find_actor(config.identifier(key: nil, value:))
          end
      end

      def maskup
        approve! if @loaded
      end

      private

      def find_actor(identifier)
        return unless identifier

        session
          .mask
          .actor_scope
          .includes(:identifiers)
          .find_by(identifiers: { value: identifier.value, type: identifier.type })
      end
    end
  end
end
