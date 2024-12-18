require_relative "boot"

require "rails/all"
require "graphql"

# Seemingly required way up here, before MasksSchema or GraphQL::Schema are autoloaded
GraphQL.eager_load! if Rails.env.production?

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "../lib/masks"

module Masks
  class Application < Rails::Application
    config.active_record.encryption.support_unencrypted_data = true
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

    config.to_prepare { Masks.reset! }

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
    config.eager_load_paths << Rails.root.join("app/prompts")

    # Used for file storage—avatars, logos, and other uploads.
    config.active_storage.service = "masks"

    # Replace the default in-process and non-durable queuing backend for Active Job.
    unless Rails.env.test?
      config.active_job.queue_adapter = :solid_queue

      if Masks.env.db_enabled?(:queue)
        config.solid_queue.connects_to = { database: { writing: :queue } }
      end

      config.cache_store = :solid_cache_store
      config.cache_store = :solid_cache_store
    end

    # Use a custom delivery_method, which allows switching
    # between methods and dynamic configuration from
    # the Masks::Installation.
    config.action_mailer.delivery_method = Masks::Mailer
    config.secret_key_base = Masks.keys.secret_key

    def fake_key
      "masks-#{Rails.env}" unless Rails.env.production?
    end

    # opt-in for Rails 8.1
    config.active_support.to_time_preserves_timezone = :zone

    # Used for ActiveRecord models that encrypt and secure data
    config.active_record.encryption.primary_key =
      Masks.keys.encryption_key&.presence || fake_key
    config.active_record.encryption.deterministic_key =
      Masks.keys.deterministic_key&.presence || fake_key
    config.active_record.encryption.key_derivation_salt =
      Masks.keys.salt&.presence || fake_key

    # Mission control
    config.mission_control.jobs.http_basic_auth_enabled = false
  end
end
