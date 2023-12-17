# frozen_string_literal: true

require "test_helper"

module Masks
  # [GET|POST] /session
  #
  # Test cases for creating new account (signup).
  #
  # This includes validations, creation via various types, and more.
  class SignupTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "POST /session requires nickname length >= 5" do
      signup_as "me"

      follow_redirect!

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/nickname is too short/, response.body)
    end

    test "POST /session requires nickname length <= 36" do
      signup_as("a" * 37)

      follow_redirect!

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/nickname is too long/, response.body)
    end

    test "POST /session requires password length >= 8" do
      signup_as "admin", password: "1234567"

      follow_redirect!

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/password is too short/, response.body)
    end

    test "POST /session requires password length <= 128" do
      signup_as "admin", password: "p" * 128

      follow_redirect!

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/password is too long/, response.body)
    end

    test "POST /session requires signups to be enabled" do
      Masks.configuration.signups = false

      signup_as "admin", password: "password"

      follow_redirect!

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/invalid credentials/, response.body)
    end

    test "POST /session creates new accounts with valid credentials" do
      refute_logged_in

      signup_as "admin", password: "password"
      assert_equal 1, Masks::Rails::Actor.count
      assert_logged_in

      new_device do
        refute_logged_in
        login_as "admin"
        assert_logged_in
      end
    end

    test "POST /session accepts an email instead of a nickname" do
      signup_as "test@example.com"

      actor = Masks::Rails::Actor.first
      email = actor.emails.first

      assert actor.nickname
      assert actor.nickname.start_with?("test")
      assert_equal "test@example.com", email.email
      refute_equal email.email, actor.nickname
    end
  end
end
