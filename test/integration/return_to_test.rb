# frozen_string_literal: true

require "test_helper"

module Masks
  # Tests for the ReturnTo credential.
  #
  # When used, this stores the last place
  class ReturnToTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "actors are redirected to / post-auth by default" do
      signup_as "admin"

      assert_equal "http://www.example.com/", headers["Location"]
    end

    test "actors are redirected to their original location post-auth" do
      get "/me?testing=true"

      signup_as "admin"

      assert_equal "http://www.example.com/me?testing=true", headers["Location"]
    end

    test "the last return_to location wins" do
      get "/me"
      get "/manage"

      signup_as "admin"

      assert_equal "http://www.example.com/manage", headers["Location"]
    end

    test "GET /session is not a valid return_to location" do
      get "/session"

      signup_as "admin"

      assert_equal "http://www.example.com/", headers["Location"]
    end

    test "GET requests are the only valid return_to locations" do
      get "/manage"
      post "/foo"

      signup_as "admin"

      assert_equal "http://www.example.com/manage", headers["Location"]
    end
  end
end
