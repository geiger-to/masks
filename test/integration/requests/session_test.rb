require "test_helper"

module Masks
  # [GET|POST] /masks/session
  #
  # by default, these endpoints act as login & signup. there
  # are a few important characteristics:
  #
  #  - new actors are signed up with a valid nickname/password
  #  - visiting the GET does not start/change the session
  #  - logged in actors are always redirected away
  #
  # there are many ways to customize these pages, but they are
  # tested elsewhere.
  class SessionTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /masks/session renders a login/signup form" do
      get "/masks/session"

      assert_equal 200, status
    end

    test "GET /masks/session does not set a session id" do
      get "/masks/session"

      assert_equal 200, status
      refute session["session_id"]
    end

    test "GET /masks/session is not available to logged in participants" do
      signup_as "test", status: 302 do
        get "/masks/session"
        assert_equal 302, status
      end
    end

    test "GET /masks/session is available to expired sessions" do
      signup_as "test", status: 302 do
        get "/private"
        assert_equal 200, status

        travel 100.years do
          get "/private"
          assert_equal 401, status

          get "/masks/session"
          assert_equal 200, status
        end
      end
    end

    test "POST /masks/session requires nickname length >= 5" do
      signup_as "me", status: 302

      assert_equal 0, Masks::Rails::Actor.count
    end

    test "POST /masks/session requires password length >= 8" do
      signup_as "test", password: "1234567", status: 302

      assert_equal 0, Masks::Rails::Actor.count
    end

    test "POST /masks/session creates new accounts with valid credentials" do
      get "/private"

      assert_equal 401, status

      signup_as "testing", password: "password", status: 302 do
        assert_equal 1, Masks::Rails::Actor.count

        get "/private"

        assert_equal 200, status
      end
    end

    test "POST /masks/session authenticates existing accounts" do
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
