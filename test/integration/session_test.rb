# frozen_string_literal: true

require "test_helper"

module Masks
  # [GET|POST] /session
  #
  # by default, these endpoints act as a login endpoint. there are many
  # ways to customize these pages, but they are tested elsewhere.
  class SessionTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /session does not set a session id" do
      get "/session"

      assert_equal 200, status
      refute session["session_id"]
    end

    test "GET /session is available to logged in participants" do
      signup_as nickname: "admin", status: 302 do
        assert_logged_in

        get "/session"
        assert_equal 200, status
      end
    end

    test "POST /session is required after 1 day" do
      signup_as nickname: "admin"
      assert_logged_in

      travel 1.day + 1.second
      refute_logged_in

      login_as "admin"
      assert_logged_in
    end

    test "POST /session authenticates existing accounts" do
      signup_as nickname: "testing", status: 302

      # this is a different test session (browser/device)
      login_as "testing", status: 302 do
        assert_logged_in
      end
    end
  end
end
