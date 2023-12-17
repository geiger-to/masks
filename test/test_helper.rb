# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [
  File.expand_path("../dummy/db/migrate", __dir__)
]
ActiveRecord::Migrator.migrations_paths << File.expand_path(
  "../db/migrate",
  __dir__
)
require "rails/test_help"
require "mocha/minitest"

require_relative "masks/test_actors/test"
require_relative "masks/test_credentials/param"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [
    File.expand_path("fixtures", __dir__)
  ]
  ActionDispatch::IntegrationTest.fixture_paths =
    ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path =
    File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

module Masks
  module TestHelper
    include ActiveSupport::Testing::TimeHelpers

    def setup
      super

      Masks.reset!
      Masks.config_path = Pathname.new(__dir__).dirname if dummy_app?
    end

    def mask_path(dir)
      Pathname.new(__dir__).join("fixtures/masks.json").join(dir)
    end

    def signup_as(actor_id, password: "password", status: 302, &block)
      open_session do |session|
        session.post "/masks/session",
                     params: {
                       session: {
                         nickname: actor_id,
                         password: password
                       }
                     }

        assert_equal status, session.response.status

        session.instance_exec(&block) if block
      end
    end

    def login_as(actor_id, password: "password", status: 302, **params, &block)
      open_session do |session|
        session.post "/masks/session",
                     params: {
                       session: {
                         nickname: actor_id,
                         password: password
                       }.merge(**params)
                     }

        assert_equal status, session.response.status

        session.instance_exec(&block) if block
      end
    end

    def add_email(
      password: "password",
      email: "test@example.com",
      verify: false
    )
      post "/masks/emails",
           params: {
             session: {
               password: password
             },
             email: {
               value: email
             }
           }

      if verify
        email = Masks::Rails::Email.where(email: email).last
        get "/masks/email/#{email.token}/verify"
      end
    end

    def add_one_time_code
      totp_secret = ROTP::Base32.random
      totp_code = ROTP::TOTP.new(totp_secret).at(Time.current)

      post "/masks/one-time-codes",
           params: {
             one_time_code: {
               code: totp_code,
               secret: totp_secret
             },
             session: {
               password: "password"
             }
           }
    end

    def reset_backup_codes(password: "password")
      post "/masks/backup-codes",
           params: {
             session: {
               password: password
             },
             backup_codes: {
               reset: true
             }
           }
    end

    def save_backup_codes(password: "password")
      post "/masks/backup-codes",
           params: {
             session: {
               password: password
             },
             backup_codes: {
               enable: true
             }
           }
    end

    def change_password(old: "password", new: "password2")
      post "/masks/password",
           params: {
             session: {
               password: old
             },
             password: {
               change: new
             }
           }
    end

    def refute_logged_in
      get "/private"
      assert_equal 401, status
    end

    def assert_logged_in
      get "/private"
      assert_equal 200, status
    end

    def dummy_app?
      false
    end
  end
end
