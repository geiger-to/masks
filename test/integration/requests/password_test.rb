require "test_helper"

module Masks
  # [GET|POST] /masks/password
  #
  # change passwords. enter old and new, and the change is accepted.
  class PasswordTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "POST requires an existing session" do
      post "/masks/sessions"

      refute session["session_id"]
    end

    test "POST requires a confirmation password" do
      signup_as "test" do
        change_password(old: "invalid", new: "password2")

        actor = Masks::Rails::Actor.find_by!(nickname: "@test")
        refute actor.changed_password_at
      end

      login_as "test", password: "password2" do
        refute_logged_in
      end

      login_as "test", password: "password" do
        assert_logged_in
      end
    end

    test "POST requires a valid password" do
      signup_as "test" do
        change_password(new: "hi")

        actor = Masks::Rails::Actor.find_by!(nickname: "@test")
        refute actor.changed_password_at
      end

      login_as "test", password: "hi" do
        refute_logged_in
      end

      login_as "test", password: "password" do
        assert_logged_in
      end
    end

    test "POST changes the actor's password given valid params" do
      signup_as "test" do
        change_password

        actor = Masks::Rails::Actor.find_by!(nickname: "@test")
        assert actor.changed_password_at
      end

      login_as "test", password: "password" do
        refute_logged_in
      end

      login_as "test", password: "password2" do
        assert_logged_in
      end
    end

    private

    def dummy_app?
      true
    end
  end
end
