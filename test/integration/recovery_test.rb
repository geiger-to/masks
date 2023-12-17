require "test_helper"

module Masks
  # [GET|POST] /recover
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

    test "GET /recover renders a recovery form" do
      get "/recover"

      assert_equal 200, status
    end

    test "GET /recover does not set a session id" do
      get "/recover"

      assert_equal 200, status
      refute session["session_id"]
    end

    test "POST /recover does not create a recovery with an invalid nickname" do
      post "/recover", params: { recover: { value: "invalid" } }

      assert_equal 0, Masks::Rails::Recovery.count
      assert_equal 302, status
    end

    test "POST /recover does not create a recovery with an invalid email" do
      signup_as "admin", status: 302 do
        add_email verify: true, email: "me@example.com"
      end

      new_device do
        post "/recover", params: { recover: { value: "test@example.com" } }

        assert_equal 0, Masks::Rails::Recovery.count
        assert_equal 302, status
      end
    end

    test "POST /recover does not create a recovery when the actor has no valid contact info" do
      signup_as "admin", status: 302

      new_device do
        post "/recover", params: { recover: { value: "admin" } }

        assert_equal 0, Masks::Rails::Recovery.count
        assert_equal 302, status
      end
    end

    test "POST /recover sends an email with a verified email address" do
      signup_as "admin", status: 302 do
        add_email verify: true
      end

      new_device do
        emails =
          capture_emails do
            post "/recover", params: { recover: { value: "admin" } }
          end

        assert_equal 1, Masks::Rails::Recovery.count
        assert_equal 302, status
        assert_equal 1, emails.length
      end
    end

    test "POST /recover allows resetting passwords" do
      signup_as "admin", status: 302 do
        add_email email: "test1@example.com", verify: true
        add_email email: "test2@example.com", verify: true
      end

      new_device do
        post "/recover", params: { recover: { value: "test2@example.com" } }

        recovery = Masks::Rails::Recovery.last
        assert_equal 1, Masks::Rails::Recovery.count
        assert_equal "test2@example.com", recovery.email
        assert_equal 302, status

        get "/recovery?token=#{recovery.token}"

        assert_equal 200, status

        post "/recovery",
             params: {
               token: recovery.token,
               recover: {
                 password: "password2"
               }
             }
      end

      new_device do
        login_as "admin", password: "password", status: 302 do
          get "/private"
          assert_equal 401, status
        end
      end

      new_device do
        login_as "admin", password: "password2", status: 302 do
          get "/private"
          assert_equal 200, status
        end
      end

      assert_equal 0, Masks::Rails::Recovery.count
    end

    test "POST /recovery requires valid passwords" do
      signup_as "admin", status: 302 do
        add_email verify: true
      end

      new_device do
        post "/recover", params: { recover: { value: "test@example.com" } }
        recovery = Masks::Rails::Recovery.last
        get "/recovery?token=#{recovery&.token}"

        post "/recovery",
             params: {
               token: recovery.token,
               recover: {
                 password: "pass"
               }
             }
      end

      new_device do
        login_as "admin", password: "pass", status: 302 do
          get "/private"
          assert_equal 401, status
        end
      end
      new_device do
        login_as "admin", password: "password", status: 302 do
          get "/private"
          assert_equal 200, status
        end
      end

      assert_equal 1, Masks::Rails::Recovery.count
    end

    test "POST /recovery only allows resets 1 hour after notification " do
      signup_as "admin", status: 302 do
        add_email verify: true
      end

      new_device do
        post "/recover", params: { recover: { value: "test@example.com" } }
        recovery = Masks::Rails::Recovery.last
        get "/recovery?token=#{recovery&.token}"

        travel (1.hour + 1.second)

        post "/recovery",
             params: {
               token: recovery.token,
               recover: {
                 password: "password2"
               }
             }
      end

      new_device do
        login_as "admin", password: "password2"
        refute_logged_in
      end

      new_device do
        login_as "admin", password: "password"
        assert_logged_in
      end

      assert_equal 1, Masks::Rails::Recovery.count
    end
  end
end
