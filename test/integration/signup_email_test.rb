# frozen_string_literal: true

require "test_helper"

module Masks
  # Integration tests for nicknames—signup, login, etc
  class EmailTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    setup do
      add_setting('nickname.required', false)
      add_setting('email.required', true)
    end

    test "POST /session requires a valid email" do
      signup_as email: "me", status: 200

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/email address is invalid/, response.body)
      refute_match(/nickname/, response.body)
    end

    test "POST /session requires email length <= 256" do
      signup_as email: "#{'a' * 256}@example.com" , status: 200

      assert_equal 0, Masks::Rails::Actor.count
      assert_match(/email address is too long/, response.body)
    end

    test "POST /signup requires an + password by default" do
      refute_logged_in

      signup_as email: 'admin@example.com'

      assert_equal 1, Masks::Rails::Actor.count
      assert_logged_in

      new_device do
        refute_logged_in
        login_as "admin@example.com"
        assert_logged_in
      end
    end
  end
end
