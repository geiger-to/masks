# frozen_string_literal: true

require "test_helper"

module Masks
  # [GET|POST] /one-time-codes
  #
  # view and configure one-time-passwords, a form of secondary authentication.
  class OneTimeCodesTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET requires a valid session" do
      get "/one-time-codes"

      assert_equal 302, status
    end

    test "GET is only available to logged in participants" do
      signup_as "admin", status: 302 do
        get "/one-time-codes"
        assert_equal 200, status
      end
    end

    test "POST requires a valid session" do
      post "/one-time-codes", params: { session: { password: "invalid" } }

      assert_equal 0, Masks::Rails::Actor.count
      assert_equal 302, status
    end

    test "POST requires a valid password" do
      signup_as "admin" do
        post "/one-time-codes", params: { session: { password: "invalid" } }
        assert_equal 302, status
      end

      actor = Masks::Rails::Actor.find_by(nickname: "admin")
      refute actor.factor2?
    end

    test "POST sets a totp_secret with a valid code" do
      signup_as "admin" do
        totp_secret = ROTP::Base32.random
        ROTP::TOTP.new(totp_secret).at(Time.current)

        post "/one-time-codes",
             params: {
               one_time_code: {
                 code: "invalid",
                 secret: totp_secret
               },
               session: {
                 password: "password"
               }
             }
        assert_equal 302, status
      end

      actor = Masks::Rails::Actor.find_by(nickname: "admin")
      refute actor.factor2?
      refute actor.totp_secret
    end

    test "POST sets a totp_secret with a valid secret" do
      signup_as "admin" do
        totp_secret = ROTP::Base32.random
        totp_code = ROTP::TOTP.new(totp_secret).at(Time.current)

        post "/one-time-codes",
             params: {
               one_time_code: {
                 code: totp_code,
                 secret: "invalid"
               },
               session: {
                 password: "password"
               }
             }
        assert_equal 302, status
      end

      actor = Masks::Rails::Actor.find_by(nickname: "admin")
      refute actor.factor2?
      refute actor.totp_secret
    end

    test "POST sets a totp_secret with a valid password, secret, and code" do
      signup_as "admin" do
        add_one_time_code
      end

      actor = Masks::Rails::Actor.find_by(nickname: "admin")
      assert actor.factor2?
      assert actor.totp_secret
    end

    test "DELETE removes a totp_secret with a valid password" do
      signup_as "admin" do
        add_one_time_code

        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        assert actor.factor2?
        assert actor.totp_secret

        delete "/one-time-codes", params: { session: { password: "password" } }
        assert_equal 302, status

        refute actor.reload.factor2?
        refute actor.reload.totp_secret
      end
    end

    test "DELETE keeps a totp_secret with an invalid password" do
      signup_as "admin" do
        add_one_time_code

        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        assert actor.factor2?
        assert actor.totp_secret

        delete "/one-time-codes", params: { session: { password: "invalid" } }
        assert_equal 302, status

        assert actor.reload.factor2?
        assert actor.reload.totp_secret
      end
    end

    test "POST /session requires a one-time-code after enabling" do
      signup_as "admin" do
        add_one_time_code
      end

      login_as "admin" do
        refute_logged_in
      end

      actor = Masks::Rails::Actor.find_by!(nickname: "admin")
      actor.totp.at(Time.current)

      login_as "admin", one_time_code: actor.totp.at(Time.current) do
        assert_logged_in
      end
    end

    test "POST /session does not require re-entering a username/password" do
      signup_as "admin" do
        add_one_time_code
      end

      login_as "admin" do
        refute_logged_in

        actor = Masks::Rails::Actor.find_by!(nickname: "admin")
        code = actor.totp.now

        post "/session", params: { session: { one_time_code: code } }

        assert_logged_in
      end
    end

    def dummy_app?
      true
    end
  end
end
