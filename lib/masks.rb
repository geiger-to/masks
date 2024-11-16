# frozen_string_literal: true

require_relative "masks/version"
require_relative "masks/fido"
require_relative "masks/timing"
require_relative "masks/scopes"

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
      installation.setting(*args, **opts)
    end

    def prompts
      @prompts ||= env.prompts.map(&:constantize)
    end

    def scopes
      @scopes ||= Masks::Scopes.new
    end

    def time
      Timing.new
    end

    def min_runtime(*args, **opts, &block)
      time.min_time(*args, **opts, &block)
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
      @installation ||=
        Masks::Installation.active.last ||
          Masks::Installation.new(settings: env)
    end

    def env
      @env ||=
        RecursiveOpenStruct.new(Rails.application.config_for("installation"))
    end

    def install!
      return unless installation.new_record?

      installation.seed!

      yield installation if block_given?
    end

    def reset!
      @scopes = nil
      @prompts = nil
      @installation = nil
      @authenticate_gql = nil
      @env = nil
    end

    def authenticate_gql
      @authenticate_gql ||=
        File.read(Rails.root.join("app", "frontend", "authenticate.graphql"))
    end
  end
end
