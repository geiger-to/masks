module Masks
  # A smaller interface that all scoped actors should adhere to.
  #
  # @see Masks::Rails::Actor Masks::Rails::Actor
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
    def has_scope?(scope)
      scopes.include?(scope.to_s)
    end

    # Returns a list of Masks::Role records for the scoped actor.
    #
    # @param [String|Object] record or type
    # @param [Hash] opts to use for additional filtering
    # @return [Masks::Role]
    def roles(record, **opts)
      raise NotImplementedError
    end

    # Returns whether or not a role is available to the scoped actor.
    #
    # @param [String|Object] record or type
    # @param [Hash] opts to use for additional filtering
    # @return [Boolean]
    def has_role?(record, **opts)
      roles(record, **opts).any?
    end

    # Similar to roles_for, except all _records_ are returned instead of the role.
    #
    # @param [String|Object] record or type
    # @param [Hash] opts to use for additional filtering
    # @return [Object] a list of records, duplicates removed
    def role_records(record_type, **opts)
      roles(record_type, **opts).map(&:record).uniq
    end
  end
end
