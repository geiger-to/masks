module Masks
  # Represents an individual mask, its properties, and methods for interpreting them.
  #
  # When a session is created it finds the first matching mask to use for
  # dictating how to control access. A Mask contains rules that allow sessions
  # to match them.
  #
  # @see Masks::Check Masks::Check
  # @see Masks::Credentials Masks::Credentials
  class Mask < ApplicationModel
    # @!attribute [rw] name
    #   a unique name for the mask
    #   @return [String]
    attribute :name
    # @!attribute [rw] skip
    #   Whether or not to skip processing by masks
    #   @return [Boolean]
    attribute :skip, default: false
    # @!attribute [rw] type
    #   A type name to inherit configuration from
    #   @return [String]
    attribute :type
    # @!attribute [rw] types
    #   A list of required type names
    #   @return [String]
    attribute :types
    # @!attribute [rw] checks
    #   A hash of checks required to pass the session
    #   @return [Hash]
    attribute :checks
    # @!attribute [rw] credentials
    #   An array of credentials that will check the session
    #   @return [Array<Class>]
    attribute :credentials
    # @!attribute [rw] scopes
    #   An array of scopes required to access the session
    #   @return [Array<String>]
    attribute :scopes
    # @!attribute [rw] request
    #   A hash of properties an HTTP request must match to use this mask
    #   @return [Hash]
    attribute :request
    # @!attribute [rw] access
    #   A list of access classes allowed during this session
    #   @return [Array<String>]
    attribute :access
    # @!attribute [rw] actor
    #   The expected class name of the actor using the sesssion, as a string
    #   @return [String]
    attribute :actor
    # @!attribute [rw] anon
    #   Whether or not to allow "anonymous" actors
    #   @return [Boolean]
    attribute :anon
    # @!attribute [rw] pass
    #   What to do when the session passes, typically a redirect uri
    #   @return [String]
    attribute :pass, default: "/"
    # @!attribute [rw] fail
    #   What to do when the session is failed by checks, credentials, or another error
    #   @return [String|Boolean]
    attribute :fail, default: true
    # @!attribute [rw] backup
    #   Whether or not to save results of masks
    #   @return [Boolean]
    attribute :backup, default: true

    # @visibility private
    attribute :config

    # @visibility private
    def initialize(attrs = {})
      if attrs[:type]
        type = attrs[:config].mask(attrs[:type])
        attrs = type.deep_merge(**attrs)
      end

      super(attrs)
    end

    # Returns the class name expected for any actor attached to this session.
    #
    # @return [String]
    def actor
      super || config.models[:actor]
    end

    # Returns the constantized version of +#actor+.
    #
    # @return [String]
    def actor_scope
      (actor.constantize unless skip?)
    end

    # Whether or not sessions matching this mask should skip all work.
    #
    # @return [Boolean]
    def skip?
      !!skip
    end

    # Whether or not anonymous actors are allowed in the session.
    #
    # @return [Boolean]
    def allow_anonymous?
      anon
    end

    # Whether or not sessions using this mask should be saved.
    #
    # Some masks definitely want this enabled, as it is what stores the results
    # of masks, credentials, and checks in the rails session. In other cases, it
    # is not necessary, for example when verifying an API key.
    def backup?
      return false if skip?

      !!backup
    end

    # A hash of check configuration, keyed by their name.
    #
    # @return [Hash]
    def checks
      return {} if skip?

      (type_config&.fetch(:checks, {}) || {}).merge(super || {})
    end

    # Converts credentials to classes before returning the list.
    #
    # @return [Array<Class>]
    # @raise Masks::Error::InvalidConfiguration
    def credentials
      return [] if skip?

      merged = [
        *(type_config&.fetch(:credentials, []) || []),
        *(super || [])
      ].uniq
      merged.map do |cls|
        case cls
        when Class
          cls
        when /[:]+/
          cls.constantize
        when String
          "Masks::Credentials::#{cls}".constantize
        else
          raise Masks::Error::InvalidConfiguration.new(cls)
        end
      end
    end

    # Returns whether or not the mask matches the passed session.
    #
    # The behaviour of this method depends on the mask's configuration.  For
    # example, a session with an anonymous actor will return true only if the
    # mask's +#allow_anonymous?+ method returns true.
    #
    # @param [Masks::Session]
    # @return [Boolean]
    def matches_session?(session)
      actor = session.actor

      return false unless actor
      return true if actor.anonymous? && allow_anonymous?

      case self.actor
      when String
        return false unless actor.is_a?(self.actor.constantize)
      when Class
        return false unless actor.is_a?(self.actor)
      else
        return false unless actor.is_a?(config.model(:actor))
      end

      return matches_scopes?(session.scopes)
    end

    # Returns whether or not the mask's request confiig matches the request passed.
    #
    # The following parameters are supported in the +request+ hash:
    #
    # - +path+ - if specified, the request path must be in this list.
    # - +method+ - if specified, the request method must be in this list.
    # - +param+ - if specified, the key must exist in the session params.
    # - +header+ - if specified, the header must be present in the request.
    #
    # @return [Boolean]
    def matches_request?(request)
      return false unless self.request
      return false unless matches_path?(request)
      return false unless matches_method?(request)

      param = self.request.fetch(:param, nil)

      if param && param != "*" && !request.params&.fetch(param.to_sym, nil)
        return false
      end

      header = self.request.fetch(:header, nil)

      return false if header && !request.headers[header]

      true
    end

    private

    # Returns whether or not the mask's allowed scopes includes one of the scopes passed.
    #
    # @return [Boolean]
    def matches_scopes?(scopes)
      return true if self.scopes.blank?

      # the mask scopes and scopes passed should have at least one match
      # otherwise this will return false because the intersection is blank
      (Array.wrap(self.scopes) & (scopes || [])).present?
    end

    def matches_path?(request)
      return true unless paths = self.request.fetch(:path, nil)

      Array
        .wrap(paths)
        .any? do |path|
          case path
          when /^r.+/
            Regexp.new(path.slice(1..)).match?(request.url)
          else
            Fuzzyurl.matches?(Fuzzyurl.mask(path: path), request.url)
          end
        end
    end

    def matches_method?(request)
      return true unless methods = self.request&.fetch(:method, nil)
      return true if !methods || methods == "*"

      Array
        .wrap(methods)
        .map(&:upcase)
        .any? do |m|
          m == request.method ||
            (request.method == "POST" && request.params[:_method]&.upcase == m)
        end
    end

    def type_config
      @type_config ||= config.mask(type) if type
    end
  end
end
