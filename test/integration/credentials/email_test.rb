require "test_helper"

module Credentials
  # Masks::Credentials::Email
  #
  # login/signup via a verified email address instead of a nickname.
  class EmailTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "POST /masks/sessions allows login via email instead of nickname" do
      actor = nil
      value = "test@example.com"

      signup_as "test", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "@test")
        post "/masks/emails", params: { session: { password: "password" }, email: { value: value } }

        email = Masks::Rails::Email.find_by!(email: value, actor: actor)
        verify_path = "/masks/email/#{email.token}/verify"
        get verify_path
      end

      login_as value.upcase do
        get "/private"
        assert_equal 200, status
        assert_equal({ "private" => "@test" }, response.parsed_body)
      end
    end

    test "POST /masks/sessions rejects unverified emails" do
      actor = nil
      value = "test@example.com"

      signup_as "test" do
        actor = Masks::Rails::Actor.find_by(nickname: "@test")
        post "/masks/emails", params: { session: { password: "password" }, email: { value: value } }
      end

      # ends up creating a new account
      login_as value.upcase do
        assert_logged_in
      end

      assert_equal 2, Masks::Rails::Actor.count
      assert_equal 2, Masks::Rails::Email.count
    end

    test "POST /masks/sessions rejects invalid email/password combinations" do
      actor = nil
      value = "test@example.com"

      signup_as "test", password: "password" do
        actor = Masks::Rails::Actor.find_by(nickname: "@test")
        post "/masks/emails", params: { session: { password: "password" }, email: { value: value } }

        email = Masks::Rails::Email.find_by!(email: value, actor: actor)
        verify_path = "/masks/email/#{email.token}/verify"
        get verify_path
      end

      login_as value.upcase, password: "invalid" do
        get "/private"
        assert_equal 401, status
      end
    end

    private

    def dummy_app?
      true
    end
  end
end
