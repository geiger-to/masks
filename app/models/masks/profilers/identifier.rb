# frozen_string_literal: true

module Masks
  module Profilers
    # Checks for an :actor given a matching identifier (nickname, email, phone, etc).
    class Identifier < Masks::Profiler
      def actor
        return unless identifier

        identifier.actor
      end

      private

      def identifier
        @identifier ||= if param
          match = profile.identifier(value: param)
          match ? Masks::Identifier.find_by(value: match.value, type: match.type) : nil
        end
      end
    end
  end
end
