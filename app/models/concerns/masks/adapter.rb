module Masks
  # An interface that all configuration adapters should adhere to.
  #
  # @see Masks::Adapters::ActiveRecord
  module Adapter
    # Creates a new adapter.
    #
    # @param [Masks::Configuration] config
    # @return [Masks::Adapter]
    def initialize(config)
      @config = config
    end

    # Returns an actor given the passed options, which may
    # contain a nickname and/or an email.
    #
    # @param [Masks::Session] session
    # @param [Hash] opts
    # @return [Masks::Actor] or nil if not found
    def find_actor(session, **opts)
      raise NotImplementedError
    end

    # Returns a list of actors matching the passed actor_ids.
    #
    # @param [Masks::Session] session
    # @param [Array] actor_ids
    # @return [Array<Masks::Actor>]
    def find_actors(session, actor_ids)
      raise NotImplementedError
    end

    # Builds an actor from the passed options, which may contain
    # a nickname or email. Additional attributes, like a password,
    # will not be supplied.
    #
    # @param [Masks::Session] session
    # @param [Hash] opts
    # @return [Masks::Actor]
    def build_actor(session, **opts)
      raise NotImplementedError
    end

    # @visibility private
    def find_recovery(session, **opts)
      raise NotImplementedError
    end

    # @visibility private
    def build_recovery(session, **opts)
      raise NotImplementedError
    end
  end
end
