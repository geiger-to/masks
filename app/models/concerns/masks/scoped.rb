# frozen_string_literal: true

module Masks
  # A smaller interface that all scoped actors should adhere to.
  #
  # @see Masks::Actor Masks::Actor
  module Scoped
    # Returns a list of scopes granted to the actor.
    #
    # @return [Array<String>] An array of scopes (as strings)
    def scopes
      raise NotImplementedError
    end

    # Returns whether or not a scope is available.
    #
    # In practice this is similar to calling +scopes.include?(scope)+,
    # but implementations may provide faster implementations.
    #
    # @param [String] scope
    # @return [Boolean]
    def scope?(scope)
      scopes.include?(scope.to_s)
    end
  end
end
