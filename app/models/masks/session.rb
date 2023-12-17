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
    attribute :name
    attribute :actor
    attribute :credentials
    attribute :actors, default: -> { [] }
    attribute :checks, default: -> { {} }
    attribute :config
    attribute :error_messages

    validates :actor, presence: true

    def id
      data[:session_id] || "anonymous"
    end

    def anonymous?
      actor&.anonymous?
    end

    # persisted session data
    def data
      raise NotImplementedError
    end

    # incoming "request" params that could affect the session
    def params
      raise NotImplementedError
    end

    def configuration
      config
    end

    def session_params
      (params[:session] || {}).deep_symbolize_keys
    end

    def actor_params
      params[:actor] || {}
    end

    # additional short-lived data (not session or request data)
    def extras(**opts)
      @extras ||= {}
      @extras.merge!(**opts.stringify_keys) if opts.keys
      @extras
    end

    def extra(key)
      @extras&.fetch(key.to_s, nil)
    end

    def actor=(actor)
      if self.actor && actor != self.actor
        errors.add(:base, :multiple_actors)
      else
        super(actor)
      end
    end

    def alternates(*actors)
      self.actors = (self.actors + actors).compact.uniq
    end

    def find_check(key)
      return unless key&.present?

      id = key.to_sym

      if !checks[id]
        defaults = mask.checks[id] || {}
        checks[id] = Check.new(key: id, **defaults)
      end

      checks.fetch(id)
    end

    def mask!
      return if mask&.skip?

      self.credentials =
        mask.credentials.map do |cls|
          cred = cls.new(session: self)

          # give credentials a chance to populate the session...
          # typically this is by providing an actor to validate
          if actor = cred.lookup
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
        self.credentials.each do |cred|
          cred.mask!

          if cred.errors.any?
            cred.errors.full_messages.each do |message|
              errors.add(:base, message)
            end
          end
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
        elsif actor&.mask!
          # finally, run through the slew of checks we need
          # newly created actors should end up in the returned list of actors
          self.actors << actor unless self.actors.include?(actor)
        else
          errors.add(:base, actor.errors.full_messages.first || :credentials)
        end

        credentials.each { |cred| cred.backup! }
        commit_to_session
      end
    end

    def cleanup!
      mask.credentials.each do |cls|
        cred = cls.new(session: self)
        cred.cleanup!
      end

      data[:masks] ||= {}
      data[:masks].delete(actor.actor_id)

      self
    end

    def access(name)
      Masks.access(name, self)
    end

    def writable?
      # certain operations should only happen when the credential is in writable
      # mode, e.g. GET vs POST requests. override this method to customize the behaviour
      true
    end

    def required?
      mask.checks.any?
    end

    def passed?
      return true if mask&.skip
      return false if !passed_checks? || errors.any?
      return false if !matches_mask?(mask)
      return false unless actor
      return false unless mask.matches_actor?(actor)
      return false unless pass?

      true
    end

    def passed_at
      return unless passed?

      checks.values.map(&:passed_at).sort.last
    end

    def past_checks
      @past_checks ||= data[:masks]&.clone || {}
    end

    def past_check
      return unless actor&.actor_id

      past_checks[actor.actor_id] ||= {}
    end

    def checks_for(key)
      return false unless past_check

      to_check =
        (
          if key
            load_checks(config.data.dig(:types, key.to_sym, :checks))
          else
            checks.slice(*mask.checks.keys)
          end
        )
      to_check
    end

    def passed_checks?(key = nil)
      return false unless past_check

      to_check =
        (
          if key
            load_checks(config.data.dig(:types, key.to_sym, :checks))
          else
            checks.slice(*mask.checks.keys)
          end
        )
      to_check.values.all?(&:passed?)
    end

    def error_message
      errors.full_messages.last
    end

    def mask
      @mask ||=
        begin
          mask = config.masks.find { |mask| matches_mask?(mask) }
          raise Error::UnknownMask.new(self) unless mask
          mask
        end
    end

    private

    def pass?
      # sub-classes can return a falsey value to fail the session for custom reasons
      true
    end

    def transaction(&block)
      if actor&.respond_to?(:transaction)
        actor.transaction(&block)
      elsif actor&.class&.respond_to?(:transaction)
        actor.class.transaction(&block)
      else
        block.call
      end
    end

    def matches_mask?(mask)
      raise NotImplementedError
    end

    def commit_to_session
      return unless mask&.backup?
      return unless actor&.backup?

      data[:masks] ||= {}
      data[:masks][actor.actor_id] = checks
        .map { |id, check| [id, check.to_session] }
        .to_h
    end

    def load_checks(defaults)
      defaults ||= {}
      past = past_check || {}

      defaults
        .deep_merge(past.deep_symbolize_keys)
        .map { |key, opts| [key, Check.new(opts.merge(key: key))] }
        .to_h
        .slice(*defaults.keys)
    end
  end
end
