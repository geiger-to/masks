# frozen_string_literal: true

require "test_helper"

module Masks
  # API requests are enabled via an Authorization header
  class ApiTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET session.json is accessible by a key" do
      signup_as nickname: "admin" do
        actor = find_actor("@admin")

        post "/keys",
             params: {
               session: {
                 password: "password"
               },
               key: {
                 name: "test",
                 secret: "test12345"
               }
             }

        assert_equal 302, status
        assert_equal 1, actor.keys.count
      end

      new_device do
        get "/session.json", headers: { Authorization: "Bearer test12345" }
        assert_equal 200, status

        get "/session.json"
        refute_equal 200, status
      end
    end

    test "GET me.json is accessible by a key" do
      signup_as nickname: "admin" do
        actor = find_actor("@admin")

        post "/keys",
             params: {
               session: {
                 password: "password"
               },
               key: {
                 name: "test",
                 secret: "test12345"
               }
             }

        assert_equal 302, status
        assert_equal 1, actor.keys.count
      end

      new_device do
        get "/me.json", headers: { Authorization: "Bearer test12345" }
        assert_equal 200, status

        get "/me.json"
        refute_equal 200, status
      end
    end

    test "keys can be granted a subset of their actor's scopes" do
      signup_as nickname: "admin" do
        actor = find_actor("@admin")
        actor.assign_scopes!("foo", "bar", "baz")

        post "/keys",
             params: {
               session: {
                 password: "password"
               },
               key: {
                 name: "test",
                 secret: "test12345",
                 scopes: %w[foo bat]
               }
             }

        assert_equal 302, status
        assert_equal 1, actor.keys.count
      end

      new_device do
        get "/session.json", headers: { Authorization: "Bearer test12345" }
        assert_equal 200, status
        assert_equal ["foo"], response.parsed_body["scopes"]
      end
    end
  end
end
