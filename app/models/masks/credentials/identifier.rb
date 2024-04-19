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
        @identifier ||= identifier_model.find_match(value: session_params[:identifier])

      end

      def identifier_model
        Masks.configuration.model(:identifier)
      end
    end
  end
end
