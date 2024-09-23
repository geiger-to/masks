# frozen_string_literal: true

require "test_helper"

module Masks
  # Integration tests for nicknames—signup, login, etc
  class NicknameTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    setup do
      add_setting('signups.enabled', true)
      add_setting('nickname.signups', true)
      add_setting('email.signups', false)
    end

    test "POST /session requires an identifier" do
      signup_as status: 200

      assert_equal 0, Masks::Rails::Actor.count
    end

    test "POST /session requires nickname length >= 5" do
      signup_as nickname: "me", status: 200

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/nickname is too short/, response.body)

      signup_as nickname: "test", password: '', status: 200

      assert_equal 0, Masks::Rails::Actor.count
      refute_match(/nickname is too short/, response.body)
    end

    test "POST /session requires nickname length <= 16" do
      signup_as nickname: "a" * 17, status: 200

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/nickname is too long/, response.body)
    end

    test "POST /session requires password length >= 8" do
      signup_as nickname: "admin", password: "1234567", status: 200

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/password is too short/, response.body)
    end

    test "POST /session requires password length <= 64" do
      signup_as nickname: "admin", password: "1" * 65, status: 200

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/password is too long/, response.body)
    end

    test "POST /session requires a nickname + password by default" do
      refute_logged_in

      signup_as nickname: 'admin'

      assert_equal 1, Masks::Rails::Actor.count
      assert_logged_in

      new_device do
        refute_logged_in
        login_as "admin"
        assert_logged_in
      end
    end
  end
end
