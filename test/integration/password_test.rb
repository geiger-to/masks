# frozen_string_literal: true

require "test_helper"

module Masks
  # [GET|POST] /password
  #
  # change passwords. enter old and new, and the change is accepted.
  class PasswordTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "POST requires a confirmation password" do
      signup_as "admin" do
        change_password(old: "invalid", new: "password2")

        actor = Masks::Rails::Actor.find_by!(nickname: "admin")
        refute actor.changed_password_at
      end

      new_device do
        login_as "admin", password: "password2"
        refute_logged_in
      end

      new_device do
        login_as "admin", password: "password"
        assert_logged_in
      end
    end

    test "POST requires a valid password" do
      signup_as "admin" do
        change_password(new: "hi")

        actor = Masks::Rails::Actor.find_by!(nickname: "admin")
        refute actor.changed_password_at
      end

      new_device do
        login_as "admin", password: "hi"
        refute_logged_in
      end

      new_device do
        login_as "admin", password: "password"
        assert_logged_in
      end
    end

    test "POST changes the actor's password given valid params" do
      signup_as "admin" do
        change_password

        actor = Masks::Rails::Actor.find_by!(nickname: "admin")
        assert actor.changed_password_at
      end

      new_device do
        login_as "admin", password: "password"
        refute_logged_in
      end

      new_device do
        login_as "admin", password: "password2"
        assert_logged_in
      end
    end
  end
end
