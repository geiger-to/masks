# frozen_string_literal: true

require_relative "masks/version"

# Top-level module for masks.
module Masks
  class << self
    def uri
      URI.parse(url)
    end

    def url
      env.url
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
      @installation&.destroy!
      @installation = nil
    end
  end
end
