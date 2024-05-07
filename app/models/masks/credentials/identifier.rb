# frozen_string_literal: true

module Masks
  module Credentials
    # Checks for an :actor given a matching identifier (nickname, email, phone, etc).
    class Identifier < Masks::Credential
      checks :actor

      def lookup
        return if actor || !identifier

        identifier.actor
      end

      def maskup
        approve! if identifier&.valid?
      end

      private

      def identifier
        @identifier ||= begin
          match = config.identifier(key: nil, value: session_params[:identifier])
          match ? config.model(:identifier).find_by(value: match.value, type: match.type) : nil
        end
      end
    end
  end
end
