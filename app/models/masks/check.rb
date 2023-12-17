module Masks
  # Checks track attempts to verify one attribute of a session, like the actor
  # or their password.
  #
  # Every session contains a list of checks that can be manipulated while it is
  # masked.  Credentials associated with the session are typical consumers of
  # checks, but direct manipulation is possible as well.
  #
  # Once a check's consumers have reported their status (approved, denied, or
  # skipped) it will report an overall status based on the results, either:
  #
  # - +passed?+ - true if attempts were made and all were approved, not skipped, or the check is optional
  # - +failed?+ - true if attempts were made and any were denied
  #
  # **Note**: Checks can exist in a middle state, neither passed or failed, in
  # the case that no attempts were made.
  #
  # @see Masks::Credential Masks::Credential
  class Check < ApplicationModel
    attribute :key
    attribute :lifetime
    attribute :optional, default: false
    attribute :attempted, default: -> { {} }
    attribute :approved
    attribute :skipped
    attribute :denied

    # Returns a hash of attempts for the check.
    #
    # Each key in the hash is the name of a specific attemptee, like a class or
    # credential. The value is a hash of data about the attempt (like when it was
    # attempted, approved, denied, and/or skipped).
    #
    # @return [Hash]
    def attempts
      attempted.deep_merge(@attempts || {}).deep_stringify_keys
    end

    # Whether or not the check is optional.
    #
    # Optional checks always return +true+ for +passed?+.
    #
    # @return Boolean
    def optional?
      optional
    end

    # Whether or not the check passed.
    #
    # +true+ if attempts were made and all were approved, not skipped, or the check is optional
    #
    # @return Boolean
    def passed?
      return true if optional? && !failed?
      return false if attempts.keys.length == 0

      attempts.all? { |id, opts| attempt_approved?(id) || attempt_skipped?(id) }
    end

    # Returns true if a specific attempt was approved.
    # @param [String] id
    # @return Boolean
    def attempt_approved?(id)
      opts = attempts.fetch(id.to_s, {})

      return self.approved if !lifetime
      return false if opts["skipped_at"]

      time =
        case opts["approved_at"]
        when nil
          return false
        when String
          Time.try(:parse, opts["approved_at"])
        else
          time
        end

      if time
        time + ActiveSupport::Duration.parse(self.lifetime) > Time.current
      else
        false
      end
    end

    # Returns true if a specific attempt was skipped.
    # @param [String] id
    # @return Boolean
    def attempt_skipped?(id)
      opts = attempts.fetch(id.to_s, {})
      opts["skipped_at"] && optional
    end

    # Approves an attempt.
    #
    # Additional metadata can be passed as keyword arguments, and it will be
    # saved alongside the attempt data.
    #
    # @param [String] id
    # @param [Hash] opts
    # @return Boolean
    def approve!(id, **opts)
      self.approved = true

      merge_attempt(
        id,
        opts.merge(approved_at: Time.current.iso8601, skipped_at: nil)
      )
    end

    # Skips an attempt. Skips count as approvals.
    #
    # Additional metadata can be passed as keyword arguments, and it will be
    # saved alongside the attempt data.
    #
    # @param [String] id
    # @param [Hash] opts
    # @return Boolean
    def skip!(id, **opts)
      self.skipped = true

      merge_attempt(
        id,
        opts.merge(approved_at: nil, skipped_at: Time.current.iso8601)
      )
    end

    # Denies an attempt.
    #
    # Additional metadata can be passed as keyword arguments, and it will be
    # saved alongside the attempt data.
    #
    # @param [String] id
    # @param [Hash] opts
    # @return Boolean
    def deny!(id, **opts)
      self.denied = true

      merge_attempt(id, opts.merge(approved_at: nil, skipped_at: nil))
    end

    # Returns the time the check passed, if it did.
    # @return [Datetime]
    def passed_at
      return unless passed?

      attempts
        .map do |id, opts|
          time = opts["approved_at"] || opts["skipped_at"]
          time = Time.try(:parse, time) if time
        end
        .compact
        .sort
        .last
    end

    # Clears all data for attempts by the given +id+.
    # @param [String] id
    # @return [Datetime]
    def clear!(id)
      @attempts&.except!(id)
      attempted.except!(id)
    end

    # Returns a version of the check intended for the rails session.
    # @return [Hash]
    def to_session
      if !lifetime
        return { optional: optional, attempted: attempted }
      else
        return { optional: optional, attempted: attempts }
      end
    end

    private

    def failed?
      return false if attempts.keys.length == 0

      attempts.any? do |id, opts|
        !attempt_approved?(id) && !attempt_skipped?(id)
      end
    end

    def merge_attempt(id, data)
      @attempts ||= {}
      @attempts[id] ||= {}
      @attempts[id].deep_merge!(data.deep_stringify_keys)
    end
  end
end
