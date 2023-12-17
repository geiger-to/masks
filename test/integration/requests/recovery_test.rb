require "test_helper"

module Masks
  # [GET|POST] /masks/recover
  #
  # recover and reset credentials:
  #
  # - GET for showing the new recovery & password reset forms
  # - POST for creating recoveries and resetting passwords
  #
  # recoveries result in short-lived tokens that are sent via
  # phone numbers/emails associated with the actor. like most
  # auth systems, proof of access to pre-verified out-of-band
  # systems is acceptable to reveal/reset account credentials.
  #
  # although un-implemented, 2factor auth is still required
  # after password reset.
  class RecoveryTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /masks/recover renders a recovery form" do
      get "/masks/recover"

      assert_equal 200, status
    end

    test "GET /masks/recover does not set a session id" do
      get "/masks/recover"

      assert_equal 200, status
      refute session["session_id"]
    end

    test "GET /masks/recover is not available to logged in participants" do
      signup_as "test", status: 302 do
        get "/masks/recover"
        assert_equal 302, status
      end
    end

    test "POST /masks/recover does not create a recovery with an invalid nickname" do
      post "/masks/recover", params: { recover: { value: "invalid" } }

      assert_equal 0, Masks::Rails::Recovery.count
      assert_equal 302, status
    end

    test "POST /masks/recover does not create a recovery with an invalid email" do
      signup_as "test", status: 302 do
        add_email verify: true, email: "me@example.com"
      end

      post "/masks/recover", params: { recover: { value: "test@example.com" } }

      assert_equal 0, Masks::Rails::Recovery.count
      assert_equal 302, status
    end

    test "POST /masks/recover does not create a recovery when the actor has no valid contact info" do
      signup_as "test", status: 302

      post "/masks/recover", params: { recover: { value: "test" } }

      assert_equal 0, Masks::Rails::Recovery.count
      assert_equal 302, status
    end

    test "POST /masks/recover sends an email with a verified email address" do
      signup_as "test", status: 302 do
        add_email verify: true
      end

      emails = capture_emails { post "/masks/recover", params: { recover: { value: "test" } } }

      assert_equal 1, Masks::Rails::Recovery.count
      assert_equal 302, status
      assert_equal 1, emails.length
    end

    test "POST /masks/recover allows resetting passwords" do
      signup_as "test", status: 302 do
        add_email email: "test1@example.com", verify: true
        add_email email: "test2@example.com", verify: true
      end

      post "/masks/recover", params: { recover: { value: "test2@example.com" } }

      recovery = Masks::Rails::Recovery.last
      assert_equal 1, Masks::Rails::Recovery.count
      assert_equal "test2@example.com", recovery.email
      assert_equal 302, status

      get "/masks/recovery?token=#{recovery.token}"

      assert_equal 200, status

      post "/masks/recovery", params: { token: recovery.token, recover: { password: "password2" } }

      login_as "test", password: "password", status: 302 do
        get "/private"
        assert_equal 401, status
      end

      login_as "test", password: "password2", status: 302 do
        get "/private"
        assert_equal 200, status
      end

      assert_equal 0, Masks::Rails::Recovery.count
    end

    test "POST /masks/recovery requires valid passwords" do
      signup_as "test", status: 302 do
        add_email verify: true
      end

      post "/masks/recover", params: { recover: { value: "test@example.com" } }
      recovery = Masks::Rails::Recovery.last
      get "/masks/recovery?token=#{recovery&.token}"

      post "/masks/recovery", params: { token: recovery.token, recover: { password: "pass" } }

      login_as "test", password: "pass", status: 302 do
        get "/private"
        assert_equal 401, status
      end

      login_as "test", password: "password", status: 302 do
        get "/private"
        assert_equal 200, status
      end

      assert_equal 1, Masks::Rails::Recovery.count
    end

    test "POST /masks/recovery only allows resets 1 hour after notification " do
      signup_as "test", status: 302 do
        add_email verify: true
      end

      post "/masks/recover", params: { recover: { value: "test@example.com" } }
      recovery = Masks::Rails::Recovery.last
      get "/masks/recovery?token=#{recovery&.token}"

      travel (1.hour + 1.second)

      post "/masks/recovery", params: { token: recovery.token, recover: { password: "password2" } }

      login_as "test", password: "password2", status: 302 do
        get "/private"
        assert_equal 401, status
      end

      login_as "test", password: "password", status: 302 do
        get "/private"
        assert_equal 200, status
      end

      assert_equal 1, Masks::Rails::Recovery.count
    end

    def dummy_app?
      true
    end
  end
end
