# frozen_string_literal: true

module Masks
  module Actors
    # An anonymous actor, used for cases where deemed acceptable.
    #
    # @see Masks::Actor
    class Anonymous < ApplicationModel
      include Masks::Actor

      attribute :session

      # Generates and returns random nickname for the actor.
      #
      # @return [String]
      def nickname
        @nickname ||= "anon:#{SecureRandom.hex}"
      end

      # @return [Array] an empty array, since no scopes are available to anonymous actors
      def scopes
        []
      end

      # This is a no-op for anonymous actors. It always returns true.
      #
      # @return [Boolean]
      def mask!
        true
      end

      # Mark this actor as anonymous.
      #
      # @return [Boolean]
      def anonymous?
        true
      end
    end
  end
end
