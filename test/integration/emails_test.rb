require "test_helper"

module Masks
  # [GET|POST|DELETE] /emails
  #
  # HTML/JSON API for added/removing emails from an account.
  # this requires a logged-in actor to use. creating/deleting
  # emails, being a sensitive action, requires a password to
  # change.
  class EmailsTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /emails redirects to login" do
      get "/emails"

      assert_equal 302, status
    end

    test "GET /emails does not set a session id" do
      get "/emails"

      refute session["session_id"]
    end

    test "GET /emails is available to logged in participants" do
      signup_as "admin" do
        get "/emails"
        assert_equal 200, status
      end
    end

    test "POST /emails requires a password" do
      signup_as "admin", password: "password" do
        add_email(password: nil)
      end

      assert_equal 0, Masks::Rails::Email.count
    end

    test "POST /emails requires a valid password" do
      signup_as "admin", password: "password" do
        add_email(password: "password2")
      end

      assert_equal 0, Masks::Rails::Email.count
    end

    test "POST /emails requires a valid email" do
      signup_as "admin", password: "password" do
        add_email(email: "nah")
      end

      assert_equal 0, Masks::Rails::Email.count
    end

    test "POST /emails creates an email with a valid password" do
      signup_as "admin", password: "password" do
        add_email
      end

      assert_equal 1, Masks::Rails::Email.count
    end

    test "POST /emails sends verification emails" do
      signup_as "admin", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        add_email(verify: true)

        assert_emails 1

        email =
          Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
        mailer = ActionMailer::Base.deliveries.last
        verify_path = "/email/#{email.token}/verify"

        assert_includes mailer.html_part.body, verify_path
      end
    end

    test "GET /email/:token/verify requires you to be logged in" do
      email = nil

      signup_as "admin", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        add_email

        email =
          Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      assert email

      new_device do
        get "/email/#{email.token}/verify"

        assert_equal 302, status

        refute email.reload.verified?
      end
    end

    test "GET /email/:token/verify cannot be expired" do
      signup_as "admin", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        add_email

        email =
          Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
        travel (1.day + 1.second)
        get "/email/#{email.token}/verify"
        refute email.reload.verified?
      end
    end

    test "GET /email/:token/verify cannot be verified by other accounts" do
      email = nil

      signup_as "admin", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        add_email

        email =
          Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      new_device do
        signup_as "another"
        assert email

        get "/email/#{email.token}/verify"

        assert_equal 200, status

        refute email.reload.verified?
      end
    end

    test "POST /emails multiple accounts can add the same unverified email" do
      signup_as "admin1", password: "password" do
        add_email
        assert_emails 1
      end

      new_device do
        signup_as "admin2", password: "password" do
          add_email
          assert_emails 2
        end
      end
    end

    test "POST /emails only one account can verify an email shared with other actors" do
      email1 = nil
      email2 = nil

      new_device do
        signup_as "admin1", password: "password"
        actor = Masks::Rails::Actor.find_by!(nickname: "admin1")
        add_email
        email1 =
          Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      new_device do
        signup_as "admin2", password: "password"
        actor = Masks::Rails::Actor.find_by!(nickname: "admin2")
        add_email(email: "test@EXAMPLE.com")
        email2 =
          Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      new_device do
        login_as "admin1"
        get "/email/#{email1.token}/verify"
        assert_equal 200, status
      end

      new_device do
        login_as "admin2"
        get "/email/#{email2.token}/verify"
        assert_equal 200, status
      end

      assert email1.reload.verified?
      refute email2.reload.verified?
    end

    test "POST /emails multiple accounts cannot add the same verified email" do
      emails =
        capture_emails do
          signup_as "admin", password: "password" do
            add_email
          end
        end
      assert_equal 1, emails.length

      emails =
        capture_emails do
          signup_as "admin", password: "password" do
            add_email
          end
        end
      assert_equal 0, emails.length
    end
  end
end
