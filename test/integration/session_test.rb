# frozen_string_literal: true

require "test_helper"

module Masks
  # [GET|POST] /session
  #
  # by default, these endpoints act as login & signup. there are many ways to
  # customize these pages, but they are tested elsewhere.
  class SessionTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /session does not set a session id" do
      get "/session"

      assert_equal 200, status
      refute session["session_id"]
    end

    test "GET /session is available to logged in participants" do
      signup_as "admin", status: 302 do
        assert_logged_in

        get "/session"
        assert_equal 200, status
      end
    end

    test "POST /session is required after 1 day" do
      signup_as "admin"
      assert_logged_in

      travel 1.day + 1.second
      refute_logged_in

      get "/me"
      assert_equal 302, status

      login_as "admin"
      assert_logged_in
    end

    test "POST /session requires nickname length >= 5" do
      signup_as "me", status: 302

      assert_equal 0, Masks::Rails::Actor.count
    end

    test "POST /session requires password length >= 8" do
      signup_as "test", password: "1234567", status: 302

      assert_equal 0, Masks::Rails::Actor.count
    end

    test "POST /session creates new accounts with valid credentials" do
      get "/private"

      assert_equal 401, status

      signup_as "testing", password: "password", status: 302 do
        assert_equal 1, Masks::Rails::Actor.count

        get "/private"

        assert_equal 200, status
      end
    end

    test "POST /session authenticates existing accounts" do
      signup_as "testing", status: 302

      # this is a different test session (browser/device)
      login_as "testing", status: 302 do
        get "/private"
        assert_equal 200, status
      end
    end

    def dummy_app?
      true
    end
  end
end
