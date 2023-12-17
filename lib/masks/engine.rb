require_relative "middleware"
module Masks
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
