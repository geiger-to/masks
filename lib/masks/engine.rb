# frozen_string_literal: true

require_relative "middleware"
module Masks
  # The Rails engine/railtie for Masks.
  #
  # Adds two initializers:
  #
  # - masks.assets.precompile - ensures masks assets are precompiled and added to the Rails asset pipeline
  # - masks.middleware - appends +Masks::Middleware+ to the middleware chain
  #
  class Engine < ::Rails::Engine
    isolate_namespace Masks

    initializer "masks.assets.precompile" do |app|
      app.config.assets.precompile += %w[masks_manifest.js] if app.config.try(
        :assets
      )
    end

    initializer "masks.middleware" do |app|
      app.config.app_middleware.use Masks::Middleware
    end
  end
end
