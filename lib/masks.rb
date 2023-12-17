require "masks/version"
require "masks/engine"
require "masks/configuration"
require "fuzzyurl"
require "valid_email"
require "phonelib"
require "rqrcode"
require "rotp"

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
    # @param [Symbol|String] type
    # @param [Masks::Session] session
    # @return [Masks::Access]
    # @raise [Masks::Error::Unauthorized] if access cannot be granted to the session passed
    # @raise [Masks::UnknownAccess] if the access type cannot be found
    def access(name, session)
      configuration.access(name).fetch(:cls).build(session)
    rescue Masks::Error::Unauthorized
      raise
    rescue StandardError => e
      raise Error::UnknownAccess.new(name)
    end

    # Returns a masked session based on the request passed.
    #
    # @param [ActionDispatch::Request] request
    # @return [Masks::Sessions::Request] session
    def request(request)
      session = Sessions::Request.new(config: configuration, request: request)
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
      session =
        Sessions::Inline.new(
          name: name,
          config: configuration,
          params: params,
          data: data
        )
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
    def config
      @config ||=
        JSON.load(File.new(config_path.join("masks.json"))).deep_symbolize_keys
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
        raise Error::InvalidConfiguration.new(path_or_config)
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
        ].find do |path|
          path&.is_a?(Symbol) || (path && File.exist?(path.join("masks.json")))
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
          raise Error::InvalidConfiguration(value)
        end
    end

    # @visibility private
    def reset!
      @configuration = @config = @config_path = nil
    end

  end
end
