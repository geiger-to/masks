# frozen_string_literal: true

require "recursive-open-struct"

require_relative "masks/version"
require_relative "masks/fido"
require_relative "masks/timing"
require_relative "masks/scopes"
require_relative "masks/mailer"
require_relative "masks/private_key"
require_relative "masks/seeds"
require_relative "masks/env"

# Top-level module for masks.
module Masks
  class AuthError < RuntimeError
    def code
      self
        .class
        .name
        .delete_suffix("Error")
        .split("::")
        .last
        .underscore
        .dasherize
    end
  end
  class InvalidStateError < AuthError
  end
  class InvalidPromptError < AuthError
  end
  class MissingStateError < AuthError
  end
  class ExpiredStateError < AuthError
  end
  class MissingClientError < AuthError
  end
  class ExpiredDeviceError < AuthError
  end
  class MismatchedClientError < AuthError
  end
  class SettledStateError < AuthError
  end

  class << self
    def uri
      URI.parse(url)
    end

    def url
      env.url
    end

    def name
      env.name
    end

    def setting(*args, **opts)
      installation&.setting(*args, **opts)
    end

    def prompts
      @prompts ||= env.prompts.map(&:constantize)
    end

    def scopes
      @scopes ||= Masks::Scopes.new
    end

    def lifetime(key)
      installation&.lifetime(key)
    end

    def time
      Timing.new
    end

    def keys
      @keys ||= PrivateKey.new(env)
    end

    def signup(identifier)
      if identifier.include?("@") && installation.emails?
        Actor.with_login_email(identifier)
      elsif installation.nicknames?
        Actor.new(nickname: identifier)
      else
        Actor.new(identifier: identifier)
      end
    end

    def identify(identifier)
      if identifier.include?("@") && installation.emails?
        Actor.from_login_email(identifier)
      elsif installation.nicknames?
        Actor.find_or_initialize_by(nickname: identifier)
      else
        Actor.new(identifier: identifier)
      end
    end

    def installation
      @installation ||= Masks::Installation.active.last
    rescue ActiveRecord::StatementInvalid
      nil
    end

    def env
      @env ||= Masks::Env.new(masks_yml)
    end

    def masks_yml
      @masks_yml ||=
        begin
          defaults = Rails.application.config_for("masks.defaults")
          path = ENV.fetch("MASKS_YML", Rails.root.join("masks.yml"))
          data = YAML.safe_lode_file(path) if File.exist?(path)
          defaults.deep_symbolize_keys.deep_merge(
            (data || {}).deep_symbolize_keys,
          )
        end
    end

    def seeds
      @seeds ||= Masks::Seeds.new(env)
    end

    def seed!
      seeds.seed!
      seeds
    end

    def reset!
      @scopes = nil
      @prompts = nil
      @installation = nil
      @authenticate_gql = nil
      @masks_yml = nil
      @seeds = nil
      @keys = nil
      @env = nil
    end

    def authenticate_gql
      @authenticate_gql ||=
        File.read(Rails.root.join("app", "frontend", "authenticate.graphql"))
    end
  end
end
