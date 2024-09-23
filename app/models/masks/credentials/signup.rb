# frozen_string_literal: true

module Masks
  module Credentials
    # Checks for an :actor given a matching identifier (nickname, email, phone, etc).
    class Signup < Masks::Credential
      checks :actor

      def lookup
        return if actor || !config.setting('signups.enabled')

        access = session.access('actor.signup')
        access.signup(**session_params.slice(:nickname, :email, :phone))
      end

      def maskup
        return unless config.setting('signups.enabled')

        approve! if actor&.valid? && actor&.signup
      end
    end
  end
end
