# frozen_string_literal: true

require "masks/version"
require "masks/engine"
require "masks/configuration"
require "fuzzyurl"
require "valid_email"
require "validates_host"
require "phonelib"
require "rqrcode"
require "rotp"
require "alba"
require "pagy"
require "device_detector"
require "active_model"
require "chronic_duration"
require "openid_connect"
require "active_record/session_store"

# Top-level module for masks.
#
# Includes helper methods for managing configuration and building
# sessions, access, etc.
module Masks
  # @visibility private
  ANON = :anon

  class << self
    def seed!
      begin
        tenant = default_tenant
      rescue Error::TenantNotFound
        tenant = nil
      end

      return unless !tenant&.seeded? && configuration.data[:seeds]

      require config_path.join(configuration.data[:seeds]).to_s
    end

    # Returns an access instance based on the type & session passed.
    #
    # @param [Symbol|String] name
    # @param [Masks::Session] session
    # @return [Masks::Access]
    # @raise [Masks::Error::Unauthorized] if access cannot be granted to the session passed
    # @raise [Masks::UnknownAccess] if the access type cannot be found
    def access(name, session, **_opts)
      configuration.access(name).fetch(:cls).build(session)
    end

    # Returns whether or not a field is accepted.
    #
    # @param [String] name
    # @return [Bool]
    def accepted?(name)
      Masks.setting("#{name}.allowed") && Masks.setting("#{name}.required")
    end

    # Returns a masked session based on the request passed.
    #
    # @param [ActionDispatch::Request] request
    # @return [Masks::Sessions::Request] session
    def request(request)
      model = configuration.model(:request)
      session = model.new(config: configuration, request:)
      session.mask!
      session
    end

    def default_tenant
      @default_tenant ||= tenant(configuration.data[:tenant])
    end

    # Returns a masked session based on the params and data passed.
    #
    # This method is useful for creating masks directly, outside of a
    # specific context like a web request.
    #
    # @param key [String]
    # @return [Masks::Profile] profile
    def tenant(key)
      return key if key.is_a?(Masks::Tenant)

      @tenants ||= {}

      if @tenants[key]
        @tenants[key].reload
      else
        @tenants[key] = Masks::Tenant.find_by(key:)
      end

      raise Error::TenantNotFound unless @tenants[key]

      @tenants[key]
    end

    # Returns a masked session based on the params and data passed.
    #
    # This method is useful for creating masks directly, outside of a
    # specific context like a web request.
    #
    # @param key [String]
    # @return [Masks::Profile] profile
    def profile(key)
      return key if key.is_a?(Masks::Profile)

      @profiles ||= {}

      if @profiles[key]
        @profiles[key].reload
      else
        @profiles[key] = Masks::Profile.find_by(key:)
      end

      raise Error::ProfileNotFound unless @profiles[key]

      @profiles[key]
    end

    # Returns a masked session based on the parameters passed.
    #
    # @param [ActionDispatch::Request] request
    # @return [Masks::Sessions::Request] session
    def session(name, *args, **opts)
      profile = profile(name)
      session =
        case args[0]
        when Rack::Request
          Masks::Sessions::Request.new(
            *(args[1..]),
            profile:,
            request: args[0],
            **opts
          )
        end

      session&.mask!
      session
    end

    # Returns a masked session based on the params and data passed.
    #
    # This method is useful for creating masks directly, outside of a
    # specific context like a web request.
    #
    # @param params [Hash]
    # @param data [Hash]
    # @yield [Masks::Sessions::Inline]
    # @return [Masks::Sessions::Inline] session
    def mask_for(param)
      case param
      when Rack::Request
      end

      model = configuration.model(:inline)
      session = model.new(name:, config: configuration, params:, data:)
      session.mask!
      yield session if session.passed? && block_given?
      session
    end

    # Yields the global masks configuration object.
    # @return [Masks::Configuration]
    # @yield [Masks::Configuration]
    def configure
      yield configuration
    end

    # Returns the global configuration object for masks.
    # @return [Masks::Configuration]
    def configuration
      @configuration ||= Masks::Configuration.new(data: config.dup)
    end

    delegate :model, :accepted?, :setting, :settings, to: :configuration

    # @visibility private
    def event(name, **opts, &block)
      ActiveSupport::Notifications.instrument("masks.#{name}", **opts) do
        block.call
      end
    end

    # @visibility private
    def config
      @config ||=
        begin
          config = load_config(config_path)
          defaults =
            load_config(
              Pathname.new(File.dirname(__dir__)),
              "masks.defaults.json"
            )
          extended =
            if config[:extend]
              # extend a "masks.json" from a gem
              load_config(gem_path(config[:extend]))
            else
              {}
            end

          merged = defaults.deep_merge(extended)
          merged = merged.except(:masks).deep_merge(config)
          merged[:masks] = [*config[:masks], *extended[:masks]] if extended[
            :masks
          ]
          merged
        end
    end

    # @visibility private
    def with_config(path_or_config)
      previous_config = @config
      previous_path = @config_path

      case path_or_config
      when String
        @config_path = Pathname.new(path_or_config)
      when Pathname
        @config_path = path_or_config
      when Hash
        @config_path = :custom
        @config = path_or_config
      else
        raise Error::InvalidConfiguration, path_or_config
      end

      yield
    ensure
      @config = previous_config
      @config_path = previous_path
    end

    # @visibility private
    def config_path
      path =
        [
          @config_path,
          ENV["MASKS_DIR"] ? Pathname.new(ENV["MASKS_DIR"]) : nil,
          Pathname.new(Dir.pwd),
          defined?(ENGINE_ROOT) ? Pathname.new(ENGINE_ROOT) : nil
        ].find do |p|
          p.is_a?(Symbol) || (p && File.exist?(p.join("masks.json")))
        end

      raise Error::ConfigurationNotFound unless path

      path
    end

    # @visibility private
    def config_path=(value)
      @config_path =
        case value
        when String
          Pathname.new(value)
        when Pathname
          value
        else
          raise Error::InvalidConfiguration, value
        end
    end

    # @visibility private
    def reset!
      @configuration = @config = @config_path = nil
    end

    def load_config(dir, path = "masks.json")
      JSON.parse(File.read(dir.join(path)), symbolize_names: true)
    end

    def gem_path(gem_name)
      begin
        # Try to require the gem
        require gem_name
      rescue LoadError
        return nil
      end

      # Get the gem specification
      spec = Gem::Specification.find_by_name(gem_name)
      Pathname.new(spec.gem_dir) if spec
    end
  end
end
