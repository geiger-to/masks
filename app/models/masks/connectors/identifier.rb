# frozen_string_literal: true

module Masks
  module Connectors
    # Checks for an :actor given a matching identifier (nickname, email, phone, etc).
    class Identifier < Masks::Connector
      def enabled?
        profile.identifiers?
      end

      def lookup
        nil unless request.writable? && session_params[:identifier]


      end

      def lookup
        return if actor || !identifier

        identifier.actor
      end

      def maskup
        approve! if identifier&.valid?
      end

      private

      def identifier_param
        session_params[:identifier] if request.writable?
      end

      def identifier
        @identifier ||= if identifier_param
          match = profile.identifier(key: nil, value: session_params[:identifier])
          match ? config.model(:identifier).find_by(value: match.value, type: match.type) : nil
        end
      end
    end
  end
end
