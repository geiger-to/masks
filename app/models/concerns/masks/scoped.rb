# frozen_string_literal: true

module Masks
  # A smaller interface that all scoped actors should adhere to.
  #
  # @see Masks::Actor Masks::Actor
  module Scoped
    MANAGE = "masks:manage"
    PASSWORD = "masks:password"

    # Returns a list of scopes granted to the actor.
    #
    # @return [Array<String>] An array of scopes (as strings)
    def scopes
      super || []
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

    def scopes_text=(text)
      self.scopes = text.split("\n").map { |line| line.split(" ") }.flatten

      sort_scopes!
    end

    def assign_scopes(*list)
      self.scopes += list
      sort_scopes!
    end

    def remove_scopes(*list)
      self.scopes -= list
      sort_scopes!
    end

    def sort_scopes!
      self.scopes = scopes.uniq.sort
    end
  end
end
