# frozen_string_literal: true

require "test_helper"

module Masks
  # API requests are enabled via an Authorization header
  class AuthorizeConfidentialTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET authorize?response_type=token redirects to login if not authenticated" do
      client = add_client(client_type: "public")

      get "/authorize",
          params: {
            response_type: "token",
            client_id: client.key,
            redirect_uri: "https://example.com",
            nonce: "12345"
          }

      assert_equal 302, status
      assert_includes headers["Location"], "/session"

      signup_as nickname: "admin"

      follow_redirect!

      admin = find_actor("@admin")

      assert_token(client, admin)
    end

    test "GET authorize?response_type=token redirects to the RP if already authenticated" do
      client = add_client(client_type: "public")

      signup_as nickname: "admin" do
        get "/authorize",
            params: {
              response_type: "token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = find_actor("@admin")

        assert_token(client, admin)
      end
    end

    test "GET authorize?response_type=id_token redirects to the RP if already authenticated" do
      client = add_client(client_type: "public")

      signup_as nickname: "admin" do
        get "/authorize",
            params: {
              response_type: "id_token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = find_actor("@admin")

        assert_id_token(client, admin)
      end
    end

    test "GET authorize?response_type=token+id_token redirects to the RP if already authenticated" do
      client = add_client(client_type: "public")

      signup_as nickname: "admin" do
        get "/authorize",
            params: {
              response_type: "token id_token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = find_actor("@admin")

        token = assert_token(client, admin)
        assert_id_token(client, admin, access_token: token.to_bearer_token)
      end
    end

    def assert_token(openid_client, actor)
      token = Masks::Rails::OpenID::AccessToken.find_by!(openid_client:, actor:)

      assert_equal 302, status
      assert_includes headers["Location"],
                      "https://example.com#access_token=#{token.token}"

      token
    end

    def assert_id_token(openid_client, actor, **with)
      id_token = Masks::Rails::OpenID::IdToken.find_by!(openid_client:, actor:)

      assert_equal 302, status
      assert_includes headers["Location"], "id_token=#{id_token.to_jwt(with)}"
    end
  end
end
