# frozen_string_literal: true

module Masks
  # An interface that all masked actors should adhere to.
  #
  # @see Masks::Scoped Masks::Scoped
  # @see Masks::Actor Masks::Actor
  # @see Actors::Anonymous
  # @see Actors::System
  module Actor
    include Scoped

    # A unique identifier for the actor.
    #
    # This value is used for internal references to actors, e.g. when they are
    # stored in the rails session.
    #
    # @return [String]
    def actor_id
      uuid
    end

    # A session identifier for the actor.
    #
    # This value is used for internal references to actors, e.g. when they are
    # stored in the rails session.
    #
    # @return [String]
    def session_key
      return if new_record? && !valid?

      Digest::MD5.hexdigest(
        [Masks.configuration.version, version, actor_id].join("-")
      )
    end

    # An internal version counter for the actor.
    #
    # Session keys use this value so they automatically expire when it changes.
    #
    # @return [String]
    def version
      raise NotImplementedError unless defined?(super)

      super
    end

    # A nickname for the actor.
    #
    # @return [String]
    def nickname
      raise NotImplementedError unless defined?(super)

      super
    end

    # Sets a password for the actor.
    #
    # @param [String] password
    # @return [String]
    def password=(password)
      raise NotImplementedError unless defined?(super)

      super
    end

    # Sets the current session on the actor.
    #
    # @param [Masks::Session] session
    # @return [String]
    def session=(session)
      raise NotImplementedError unless defined?(super)

      super
    end

    # Validates the given password.
    #
    # @param [String] password
    # @return [Boolean]
    def authenticate(password)
      raise NotImplementedError unless defined?(super)

      super
    end

    # Returns a list of scopes granted to the actor.
    #
    # @return [Array<String>] An array of scopes (as strings)
    def scopes
      raise NotImplementedError
    end

    # A callback that is invoked for masked sessions involving this actor.
    #
    # This method is only called when everything else—credentials, checks,
    # and other mask rules—have passed. If this method returns a truthy value
    # the session will pass, otherwise it will fail.
    #
    # This is a great place to add final checks, validations, and onboarding
    # data to the actor before saving it.
    #
    # @return [Boolean]
    def mask!
      raise NotImplementedError
    end

    # Whether or not the actor requires a second layer of authentication.
    #
    # @return [Boolean]
    def factor2?
      false
    end

    # Whether or not the actor is anonymous, e.g. instantiated but un-identified.
    #
    # @return [Boolean]
    def anonymous?
      false
    end

    # Whether or not to save the results of any masked sessions involving this actor.
    #
    # Typically this is best controlled at the mask level, but there are some cases
    # where it is useful to control at the actor-level. For example, the implementation
    # for anonymous actors always returns `true` for this method, so that anonymous
    # actors never end up in the rails session or other databases.
    #
    # @return [Boolean]
    def backup?
      !anonymous?
    end
  end
end
