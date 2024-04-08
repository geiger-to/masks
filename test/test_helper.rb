# frozen_string_literal: true

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

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [
    File.expand_path("fixtures", __dir__)
  ]
  ActionDispatch::IntegrationTest.fixture_paths =
    ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path =
    "#{File.expand_path("fixtures", __dir__)}/files"
  ActiveSupport::TestCase.fixtures :all
end

module UserAgentExtension
  def process(*args, **opts)
    opts[:headers] ||= {}
    opts[:headers][
      "HTTP_USER_AGENT"
    ] ||= "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:100.0) Gecko/20100101 Firefox/100.0"
    super(*args, **opts)
  end
end

ActionDispatch::Integration::Session.prepend UserAgentExtension

module Masks
  module TestHelper
    include ActiveSupport::Testing::TimeHelpers

    def setup
      super

      Masks.reset!
      Masks.config_path = masks_json if masks_json
    end

    def new_device(&)
      open_session { |session| session.instance_exec(&) }
    end

    def signup_as(
      actor_id,
      password: "password",
      session: nil,
      status: 302,
      &block
    )
      session ||= self
      session.post "/session",
                   params: {
                     session: {
                       nickname: actor_id,
                       password:
                     }
                   }

      assert_equal status, session.response.status

      session.instance_exec(&block) if block
    end

    def login_as(
      actor_id,
      password: "password",
      session: nil,
      status: 302,
      **params,
      &block
    )
      session ||= self
      session.post "/session",
                   params: {
                     session: { nickname: actor_id, password: }.merge(**params)
                   }

      assert_equal status, session.response.status

      session.instance_exec(&block) if block
    end

    def add_email(
      password: "password",
      email: "test@example.com",
      verify: false
    )
      post "/emails",
           params: {
             session: {
               password:
             },
             email: {
               value: email
             }
           }

      return unless verify

      email = Masks::Rails::Email.where(email:).last
      get "/email/#{email.token}/verify"
    end

    def add_one_time_code
      totp_secret = ROTP::Base32.random
      totp_code = ROTP::TOTP.new(totp_secret).at(Time.current)

      post "/one-time-codes",
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
      post "/backup-codes",
           params: {
             session: {
               password:
             },
             backup_codes: {
               reset: true
             }
           }
    end

    def save_backup_codes(password: "password")
      post "/backup-codes",
           params: {
             session: {
               password:
             },
             backup_codes: {
               enable: true
             }
           }
    end

    def change_password(old: "password", new: "password2")
      post "/password",
           params: {
             session: {
               password: old
             },
             password: {
               change: new
             }
           }
    end

    def add_client(name: "test", redirect_uris: "https://example.com", **opts)
      Masks::Rails::OpenID::Client.create!(name:, redirect_uris:, **opts)
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

    def masks_json
      Pathname.new(__dir__).dirname
    end
  end
end
