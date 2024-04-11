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

# Top-level module for masks.
#
# Includes helper methods for managing configuration and building
# sessions, access, etc.
module Masks
  # @visibility private
  ANON = :anon

  class << self
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

    # Returns a masked session based on the params and data passed.
    #
    # This method is useful for creating masks directly, outside of a
    # specific context like a web request.
    #
    # @param params [Hash]
    # @param data [Hash]
    # @yield [Masks::Sessions::Inline]
    # @return [Masks::Sessions::Inline] session
    def mask(name, params: {}, **data)
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
            if config[:extend]
              # extend a "masks.json" from a gem
              load_config(gem_path(config[:extend]))
            else
              {}
            end

          config = defaults.except(:masks).deep_merge(config)
          config[:masks] = [*config[:masks], *defaults[:masks]] if defaults[
            :masks
          ]
          config
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

      result = yield
    ensure
      @config = previous_config
      @config_path = previous_path

      result
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

    def load_config(dir)
      JSON.parse(File.read(dir.join("masks.json")), symbolize_names: true)
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
