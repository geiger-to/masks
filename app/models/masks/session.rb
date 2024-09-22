# frozen_string_literal: true

module Masks
  # Interface for sessions, which keep track of attempts to access resources.
  #
  # The helper methods provided by the +Masks+ module are wrappers around
  # the +Masks::Session+ class. Masks creates different types of sessions
  # dependending on the context, calls their +mask!+ method, and records
  # the results.
  #
  # This class is designed to be sub-classed. Sub-classes must provide a +data+,
  # +params+, and +matches_mask?+ method. The latter method is how a session
  # is able to find a suitable mask from the configuration.
  #
  # After a session's +mask!+ method is called, it will report an +actor+,
  # whether or not the checks it ran have +passed?+, and any +errors+ (just like
  # an +ActiveRecord+ model).
  #
  # @see Masks::Check Masks::Check
  # @see Masks::Credentials Masks::Credentials
  # @see Masks::Sessions Masks::Sessions
  # @see Masks::Mask Masks::Mask
  class Session < ApplicationModel
    CHECK_KEY = :masks

    attribute :name
    attribute :actor
    attribute :scopes
    attribute :scoped
    attribute :credentials
    attribute :checks, default: -> { {} }
    attribute :config
    attribute :error_messages

    validates :actor, presence: true

    class << self
      def mask!(*args, **opts)
        new(*args, **opts).tap(&:mask!)
      end
    end

    # Returns an identifier for the session.
    #
    # This value can be used to reference the session in backend processes.
    #
    # @return [String]
    def id
      data[:session_id] || "anonymous"
    end

    # Returns the session's IP address or nil in cases where no IP is present.
    #
    # @return [String] or nil
    def ip_address
      nil
    end

    # Returns the session's user agent.
    #
    # Ideally this is always specified, but there are contexts where it cannot be supplied.
    #
    # @return [String] or nil
    def user_agent
      nil
    end

    # Returns a user-supplied "fingerprint" for the session.
    #
    # Generally speaking, this is a low-trust value.
    #
    # @return [String] or nil
    def fingerprint
      nil
    end

    # Returns a detected device based on the +user_agent+.
    #
    # If the user agent isn't present a detected device is still returned, but
    # it's attributes will return nil and its +known?+ method will return false.
    #
    # @return [DeviceDetector]
    def device
      @device ||= DeviceDetector.new(user_agent)
    end

    # Whether or not the session's actor is anonymous?
    delegate :anonymous?, to: :actor, allow_nil: true

    # A hash of persisted session data.
    #
    # @return [Hash]
    def data
      raise NotImplementedError
    end

    # Incoming "request" params that could affect the session.
    #
    # @return [Hash]
    def params
      raise NotImplementedError
    end

    # Normalizes +params[:session]+ and returns it.
    #
    # Paramaters intended for the session should be nested under the +session+ key.
    #
    # @return [Hash]
    def session_params
      (params[:session] || {}).deep_symbolize_keys
    end

    # Additional short-lived data (not session or request data)
    #
    # @param [Hash] opts a hash of extra data to merge
    def extras(**opts)
      @extras ||= {}
      @extras.merge!(**opts.stringify_keys) if opts.keys
      @extras
    end

    # Returns a specific key from the session +extras+ or nil.
    #
    # @param [Symbol|String] key the name of the key
    # @return [any]
    def extra(key)
      @extras&.fetch(key.to_s, nil)
    end

    # Sets the actor on the session.
    #
    # If the actor is already set then an error will be
    # added to the session, preventing it from passing.
    #
    # @param [Masks::Actor] actor
    def actor=(actor)
      if self.actor && actor != self.actor
        errors.add(:base, :multiple_actors)
      else
        super
      end
    end

    delegate :scopes,
             :scope?,
             :role?,
             :roles_for,
             :role_records,
             to: :scoped,
             allow_nil: true

    # Returns the "scoped" actor, which may be different from the actor itself.
    #
    # For example, in some cases access is gained via an API key or some
    # person/system with "admin" rights. In both cases there is an agent
    # agent operating the system that is granted the ability to behave
    # as someone else.
    #
    # This scoped actor may respond to the methods available for interrogating
    # scopes and roles differently than the actor itself—e.g. an access key may
    # return a smaller set of scopes than the actor. An admin may temporarily
    # allow additional scopes...
    #
    # @return [Masks::Scoped]
    def scoped
      super || actor
    end

    # Returns a check by the name provided.
    #
    # @param [Symbol|String] key
    # @return [Masks::Check]
    def find_check(key)
      return unless key&.present?

      id = key.to_sym

      unless checks[id]
        defaults = mask.checks[id] || {}
        checks[id] = Check.new(key: id, **defaults)
      end

      checks.fetch(id)
    end

    # Masks the session.

    # @return [self]
    def mask!
      Masks.event "session", session: self do
        return if mask&.skip?

        self.credentials =
          mask.credentials.map do |cls|
            cred = cls.new(session: self)

            # give credentials a chance to populate the session...
            # typically this is by providing an actor to validate
            if (actor = cred.lookup)
              self.actor = actor
            end

            cred
          end

        self.checks = load_checks(mask.checks)

        # session data can reveal checks that are still valid
        # based on duration. skip checking again in this case.
        return if passed?

        transaction do
          # each credential is given a chance to mask the session
          credentials.each do |cred|
            cred.mask!

            if cred.errors.any?
              cred.errors.full_messages.each do |message|
                errors.add(:base, message)
              end
            end
          rescue RuntimeError
            return cleanup!
          end

          actor&.session = self

          # to ensure that we are going to be passed?
          if actor && !actor.valid?(:mask)
            actor.errors.full_messages.each do |message|
              errors.add(:base, message)
            end
          elsif !passed_checks?
            errors.add(:base, :credentials)
          elsif !passed?
            errors.add(:base, :access)
          elsif !actor&.mask!
            errors.add(:base, actor.errors.full_messages.first || :credentials)
          end

          credentials.each(&:backup!)
          commit_to_session
        end

        self
      end
    end

    # Cleans up all session data, akin to logout.
    #
    # @return [self]
    def cleanup!
      Masks.event "cleanup", session: self do
        mask.credentials.each do |cls|
          cred = cls.new(session: self)
          cred.cleanup!
        end

        if actor
          data[:masks] ||= {}
          data[:masks].delete(actor.session_key)
        end

        self
      end
    end

    # Returns an access class based on this session.
    #
    # @param [String] name
    # @raise [Masks::Error]
    # @return [Masks::Access]
    def access(name)
      Masks.access(name, self)
    end

    # Whether or not the session is "writable".
    #
    # Some credentials only allow certain operations when in
    # this state, which is akin to the difference between
    # GET and POST.
    #
    # @return [Boolean]
    def writable?
      # certain operations should only happen when the credential is in writable
      # mode, e.g. GET vs POST requests. override this method to customize the behaviour
      true
    end

    # Whether or not to allow access to the actor identified by the session.
    #
    # This method aims to be a simple test to determine whether or not
    # a session has passed all checks.
    #
    # @return [Boolean]
    def passed?
      return true if mask&.skip?
      return false if !passed_checks? || errors.any?
      return false unless matches_mask?(mask)
      return false unless actor
      return false unless mask.matches_session?(self)
      return false unless pass?

      true
    end

    # Returns the time the session passed all checks, provided they have.
    #
    # This method may return a time in the past—for example when credential
    # checks passed in that past, but within their configured lifetime.
    #
    # @return [Datetime]
    def passed_at
      return unless passed?

      checks.values.map(&:passed_at).compact.max
    end

    # Returns a hash of all checks that happened in the past.
    #
    # These checks are stored in the session data, under +CHECK_KEY+.
    #
    # @return [Hash]
    def past_checks
      @past_checks ||= data[CHECK_KEY]&.clone || {}
    end

    # Returns a hash of checks for a given type.
    #
    # If any of the checks in the type exist on the session, it will be
    # returned. Otherwise a new check is constructed and included in the
    # set.
    #
    # This is useful for introspecting the state of a session according
    # to the rules of another type, but keep in mind that this does not
    # allow the credentials configured on the type to run, so checks
    # may report a passing status despite being stale.
    #
    # @return [Hash]
    def checks_for(type)
      return false unless actor_checks

      load_checks(config.data.dig(:types, type.to_sym, :checks))
    end

    # Returns whether or not the session checks report a passing status.
    #
    # Pass an optional type to see if the session's checks pass according
    # to the type's checks, useful for determining the potential state of
    # a session.
    #
    # @param [String] type
    # @return [Boolean]
    def passed_checks?(type = nil)
      return true unless checks.any?
      return false unless actor_checks

      to_check =
        (
          if type
            load_checks(config.data.dig(:types, type.to_sym, :checks))
          else
            checks.slice(*mask.checks.keys)
          end
        )
      to_check.values.all?(&:passed?)
    end

    # A single error message for the session, as opposed to a list of errors
    #
    # @return [String] or nil
    def error_message
      errors.full_messages.last
    end

    # The mask the session will use.
    #
    # @return [Masks::Mask]
    # @raise [Masks::Error::UnknownMask]
    def mask
      @mask ||=
        begin
          mask = config.masks.find { |m| matches_mask?(m) }
          raise Error::UnknownMask, self unless mask
          mask
        end
    end

    protected

    # Whether or not the given mask matches the session.
    #
    # Sub-classes must implement this method, which is used to match the session
    # itself to a mask from +Masks.configuration+.
    #
    # @return [Boolean]
    def matches_mask?(mask)
      raise NotImplementedError
    end

    # Sub-classes can return a falsey value to fail the session for any reason.
    #
    # @return [Boolean]
    def pass?
      true
    end

    private

    def transaction(&block)
      if actor.respond_to?(:transaction)
        actor.transaction(&block)
      elsif actor&.class.respond_to?(:transaction)
        actor.class.transaction(&block)
      else
        block.call
      end
    end

    def commit_to_session
      return unless mask&.backup?
      return unless actor&.backup?

      data[:masks] ||= {}
      data[:masks][actor.session_key] ||= {}
      checks.each do |id, check|
        data[:masks][actor.session_key][id.to_s] = check.to_session
      end
    end

    def load_checks(defaults)
      defaults ||= {}
      past = actor_checks || {}

      defaults
        .deep_merge(past.deep_symbolize_keys)
        .to_h { |key, opts| [key, Check.new(opts.merge(key:))] }
        .slice(*defaults.keys)
    end

    def actor_checks
      return unless actor&.session_key

      past_checks[actor.session_key] ||= {}
    end
  end
end
