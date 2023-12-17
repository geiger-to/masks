require "set"
require "recursive-open-struct"

module Masks
  # Container for masks configuration data.
  class Configuration
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Attributes
    include ActiveModel::Serializers::JSON

    attribute :data
    attribute :adapter, default: "Masks::Adapters::ActiveRecord"
    attribute :site_name
    attribute :site_url
    attribute :site_logo
    attribute :site_links
    attribute :lifetimes
    attribute :masks
    attribute :models

    # Returns all configuration data as +RecursiveOpenStruct+.
    #
    # @return RecursiveOpenStruct
    def dat
      RecursiveOpenStruct.new(data)
    end

    # Returns a string to use as the "issuer" for various secrets—TOTP, JWT, etc.
    # @return [String]
    def issuer
      site_name
    end

    # Returns the site name, used for presentation.
    # @return [String]
    def site_name
      super || data.fetch(:name, "masks")
    end

    # Returns the site title, used primarily in meta tags.
    # @return [String]
    def site_title
      super || data.fetch(:title, "")
    end

    # Returns the canonical url for the site.
    # @return [String]
    def site_url
      super || data.fetch(:url, nil)
    end

    # Returns a path to the site logo, displayed in various places.
    # @return [String]
    def site_logo
      super || data.fetch(:logo, nil)
    end

    # A hash of links—urls to various places on the frontend.
    #
    # These default to generated rails routes, but can be overridden
    # where necessary.
    #
    # @return [Hash]
    def site_links
      super || { recover_credentials: rails_url.recover_path }
    end

    # A hash of expiration times for various resources.
    #
    # These values are used to override expiration times for things like
    # password reset emails and other time-based authentication methods.
    #
    # @return [Hash]
    def lifetimes
      (super || dat.lifetimes&.to_h || {})
        .map { |name, seconds| [name, seconds.to_i.seconds] }
        .to_h
    end

    # A hash of default models the app relies on.
    #
    # The following keys are available:
    #
    #   actor: +Masks::Rails::Actor+
    #   role: +Masks::Rails::Role+
    #   scope: +Masks::Rails::Scope+
    #   email: +Masks::Rails::Email+
    #   recovery: +Masks::Rails::Recovery+
    #
    # This makes it easy to provide a substitute for key models
    # while still relying on the base active record implementation.
    #
    # @return [Hash{Symbol => String}]
    def models
      {
        actor: "Masks::Rails::Actor",
        role: "Masks::Rails::Role",
        scope: "Masks::Rails::Scope",
        email: "Masks::Rails::Email",
        recovery: "Masks::Rails::Recovery"
      }.merge(super || {})
    end

    # Returns a model +Class+.
    #
    # @return [Class]
    def model(name)
      models[name]&.constantize
    end

    # Returns configuration data for a given mask type.
    #
    # @param [String] type
    # @return [Hash]
    def mask(type)
      config = data.dig(:types, type.to_sym)
      raise Masks::Error::InvalidConfiguration.new(type) unless config
      config
    end

    # Returns all configured masks.
    #
    # @return [Array<Masks::Mask>]
    def masks
      @masks ||=
        begin
          masks = super || data.fetch(:masks, [])
          masks.map do |opts|
            case opts
            when Masks::Mask
              opts
            when Hash
              Masks::Mask.new(opts.merge(config: self))
            end
          end
        end
    end

    # Returns configuration data for the given access name.
    # @param [String] name
    # @return [Hash]
    def access(name)
      defaults = Masks::Access.defaults(name)
      raise Masks::UnknownAccess.new(name) unless defaults
      defaults.deep_merge(access_types&.fetch(name, {}))
    end

    # Returns configuration data for all access types.
    #
    # This does not include defaults created with +Masks::Access.access+.
    #
    # @return [Hash]
    def access_types
      @access_types ||=
        begin
          types = data.fetch(:access, {})
          types
            .map do |name, opts|
              [name, opts.merge(name: name, cls: opts[:cls]&.constantize)]
            end
            .to_h
        end
    end

    delegate :redirect_url,
             :find_actor,
             :find_actors,
             :build_actor,
             :find_recovery,
             :build_recovery,
             to: :adapt

    private

    def rails_url
      Masks::Engine.routes.url_helpers
    end

    def adapt
      @adapt =
        case adapter
        when String
          adapter.constantize.new(self)
        when Class
          adapter.new(self)
        else
          raise Masks::Error::InvalidConfiguration.new(adapter)
        end
    end
  end
end
