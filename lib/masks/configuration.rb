# frozen_string_literal: true

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
    attribute :name
    attribute :adapter, default: "Masks::Adapters::ActiveRecord"
    attribute :theme
    attribute :site_name
    attribute :site_url
    attribute :site_links
    attribute :site_logo
    attribute :lifetimes
    attribute :openid
    attribute :masks
    attribute :models
    attribute :version

    # Returns all configuration data as +RecursiveOpenStruct+.
    #
    # @return RecursiveOpenStruct
    def dat
      RecursiveOpenStruct.new(data)
    end

    # Returns a string to use as the "issuer" for various secrets—TOTP, JWT, etc.
    # @return [String]
    def issuer
      data.fetch(:name, "masks").parameterize
    end

    # Returns a site theme to use on the frontend.
    # @return [String]
    def theme
      super || data.fetch(:theme, "dark")
    end

    # Returns the site logo, used for visual identification of the site.
    # @return [String]
    def site_logo
      super || data.fetch(:logo, nil)
    end

    # Returns the site name, used for referring to the site (e.g. in the logo).
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

    # Returns a string to use as the "issuer" for various secrets—TOTP, JWT, etc.
    # @return [String]
    def openid
      {
        scopes: %w[openid profile email address phone],
        subject_types: %w[public pairwise],
        response_types: %w[code token id_token],
        grant_types: %w[
          client_credentials
          authorization_code
          implicit
          refresh_token
        ],
        pairwise_salt: "masks"
      }.merge(super || data.fetch(:openid, {}))
    end

    # A hash of links—urls to various places on the frontend.
    #
    # These default to generated rails routes, but can be overridden
    # where necessary.
    #
    # @return [Hash]
    def site_links
      {
        root: rails_url.try(:root_path) || "/",
        recover: rails_url.recover_path,
        login: rails_url.session_path,
        after_login: rails_url.session_path,
        after_logout: rails_url.session_path
      }.merge(super || data.fetch(:links, {}))
    end

    # Returns the current global session key.
    # @return [String]
    def version
      super || "v1"
    end

    # A hash of expiration times for various resources.
    #
    # These values are used to override expiration times for things like
    # password reset emails and other time-based authentication methods.
    #
    # @return [Hash]
    def lifetimes
      (super || dat.lifetimes&.to_h || {}).transform_values do |seconds|
        seconds.to_i.seconds
      end
    end

    # A hash of default models the app relies on.
    #
    # This makes it easy to provide a substitute for key models
    # while still relying on the base active record implementation.
    #
    # @return [Hash{Symbol => String}]
    def models
      {
        actor: "Masks::Rails::Actor",
        scope: "Masks::Rails::Scope",
        role: "Masks::Rails::Role",
        email: "Masks::Rails::Email",
        recovery: "Masks::Rails::Recovery",
        device: "Masks::Rails::Device",
        key: "Masks::Rails::Key",
        openid_client: "Masks::Rails::OpenID::Client",
        openid_access_token: "Masks::Rails::OpenID::AccessToken",
        openid_id_token: "Masks::Rails::OpenID::IdToken",
        openid_authorization: "Masks::Rails::OpenID::Authorization",
        session_json: "Masks::SessionResource",
        request: "Masks::Sessions::Request",
        inline: "Masks::Sessions::Inline",
        access: "Masks::Sessions::Access"
      }.merge(super || data.fetch(:models, {}))
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
      raise Masks::Error::InvalidConfiguration, type unless config
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
      raise Masks::Error::UnknownAccess, name unless defaults

      defaults.deep_merge(access_types&.fetch(name, {}))
    end

    # Returns configuration data for all access types.
    #
    # This does not include defaults created with +Masks::Access.access+.
    #
    # @return [Hash]
    def access_types
      data
        .fetch(:access, {})
        .to_h do |name, opts|
          [name, opts.merge(name:, cls: opts[:cls]&.constantize)]
        end
    end

    # Setter for whether or not sigups are allowed.
    #
    # @param [Boolean] value
    def signups=(value)
      data[:signups] = value
    end

    # Whether or not sigups are allowed.
    #
    # @return [Boolean]
    def signups?
      data[:signups]
    end

    delegate :find_key,
             :find_actor,
             :find_actors,
             :build_actor,
             :find_device,
             :find_recovery,
             :build_recovery,
             :expire_actors,
             :expire_recoveries,
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
          raise Masks::Error::InvalidConfiguration, adapter
        end
    end
  end
end
