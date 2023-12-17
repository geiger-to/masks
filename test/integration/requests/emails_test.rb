require "test_helper"

module Masks
  # [GET|POST|DELETE] /masks/emails
  #
  # HTML/JSON API for added/removing emails from an account.
  # this requires a logged-in actor to use. creating/deleting
  # emails, being a sensitive action, requires a password to
  # change.
  class EmailsTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /masks/emails redirects to login" do
      get "/masks/emails"

      assert_equal 302, status
    end

    test "GET /masks/emails does not set a session id" do
      get "/masks/emails"

      refute session["session_id"]
    end

    test "GET /masks/emails is available to logged in participants" do
      signup_as "test" do
        get "/masks/emails"
        assert_equal 200, status
      end
    end

    test "POST /masks/emails requires a password" do
      signup_as "test", password: "password" do
        add_email(password: nil)
      end

      assert_equal 0, Masks::Rails::Email.count
    end

    test "POST /masks/emails requires a valid password" do
      signup_as "test", password: "password" do
        add_email(password: "password2")
      end

      assert_equal 0, Masks::Rails::Email.count
    end

    test "POST /masks/emails requires a valid email" do
      signup_as "test", password: "password" do
        add_email(email: "nah")
      end

      assert_equal 0, Masks::Rails::Email.count
    end

    test "POST /masks/emails creates an email with a valid password" do
      signup_as "test", password: "password" do
        add_email
      end

      assert_equal 1, Masks::Rails::Email.count
    end

    test "POST /masks/emails sends verification emails" do
      signup_as "test", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "@test")
        add_email(verify: true)

        assert_emails 1

        email = Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
        mailer = ActionMailer::Base.deliveries.last
        verify_path = "/masks/email/#{email.token}/verify"

        assert_includes mailer.html_part.body, verify_path
      end
    end

    test "GET /masks/email/:token/verify requires you to be logged in" do
      email = nil

      signup_as "test", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "@test")
        add_email

        email = Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      assert email

      get "/masks/email/#{email.token}/verify"

      assert_equal 302, status

      refute email.reload.verified?
    end

    test "GET /masks/email/:token/verify cannot be expired" do
      signup_as "test", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "@test")
        add_email

        email = Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
        travel (1.day + 1.second)
        get "/masks/email/#{email.token}/verify"
        refute email.reload.verified?
      end
    end

    test "GET /masks/email/:token/verify cannot be verified by other accounts" do
      email = nil

      signup_as "test", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "@test")
        add_email

        email = Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      signup_as "another" do
        assert email

        get "/masks/email/#{email.token}/verify"

        assert_equal 200, status

        refute email.reload.verified?
      end
    end

    test "POST /masks/emails multiple accounts can add the same unverified email" do
      signup_as "test", password: "password" do
        add_email
        assert_emails 1
      end

      signup_as "test", password: "password" do
        add_email
        assert_emails 1
      end
    end

    test "POST /masks/emails only one account can verify an email shared with other actors" do
      email1 = nil
      email2 = nil

      signup_as "test1", password: "password" do
        actor = Masks::Rails::Actor.find_by!(nickname: "@test1")
        add_email
        email1 = Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      signup_as "test2", password: "password" do
        actor = Masks::Rails::Actor.find_by!(nickname: "@test2")
        add_email(email: "TEST@EXAMPLE.com")
        email2 = Masks::Rails::Email.find_by!(email: "test@example.com", actor: actor)
      end

      login_as "test1" do
        get "/masks/email/#{email1.token}/verify"
        assert_equal 200, status
      end

      login_as "test2" do
        get "/masks/email/#{email2.token}/verify"
        assert_equal 200, status
      end

      assert email1.reload.verified?
      refute email2.reload.verified?
    end

    test "POST /masks/emails multiple accounts cannot add the same verified email" do
      emails =
        capture_emails do
          signup_as "test", password: "password" do
            add_email
          end
        end
      assert_equal 1, emails.length

      emails =
        capture_emails do
          signup_as "test", password: "password" do
            add_email
          end
        end
      assert_equal 0, emails.length
    end

    private

    def dummy_app?
      true
    end
  end
end
