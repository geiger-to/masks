# frozen_string_literal: true

module Masks
  module Credentials
    # Checks :key given a valid Authorization header.
    class Key < Masks::Credential
      checks :key

      attribute :accessed

      def lookup
        secret = session.request.authorization&.split&.last
        key = session.config.find_key(session, secret:)

        return unless key

        session.extras(key:)
        session.scoped = key
        self.accessed = true
        key.actor
      end

      def maskup
        key = session.extra(:key)

        if key&.actor == session&.actor && session.scoped == key
          approve!
        else
          deny!
        end
      end

      def backup
        session.extra(:key).touch(:accessed_at) if session&.passed? && accessed
      end
    end
  end
end
