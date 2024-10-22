require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "../lib/masks"

module Masks
  class Application < Rails::Application
    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags = [
      # Rails query log tags:
      :application,
      :controller,
      :action,
      :job,
      # GraphQL-Ruby query log tags:
      current_graphql_operation: -> { GraphQL::Current.operation_name },
      current_graphql_field: -> { GraphQL::Current.field&.path },
      current_dataloader_source: -> do
        GraphQL::Current.dataloader_source_class
      end,
    ]
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Used for file storage—avatars.
    config.active_storage.service = "masks"
    config.active_job.queue_adapter = :good_job unless Rails.env.test?

    # Used for signing values, cookies, etc
    credentials.secret_key_base = Masks.env.secret_key if Masks
      .env
      .secret_key
      &.present?

    def fake_key
      "masks-#{Rails.env}" unless Rails.env.production?
    end

    # Used for ActiveRecord models that encrypt and secure data
    config.active_record.encryption.primary_key =
      Masks.env.encryption_key&.presence || fake_key
    config.active_record.encryption.deterministic_key =
      Masks.env.deterministic_key&.presence || fake_key
    config.active_record.encryption.key_derivation_salt =
      Masks.env.salt&.presence || fake_key
  end
end
