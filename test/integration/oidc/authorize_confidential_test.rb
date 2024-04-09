# frozen_string_literal: true

require "test_helper"

module Masks
  # API requests are enabled via an Authorization header
  class AuthorizeCodeTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET authorize assigns the first redirect_uri if none is configured" do
      client = add_client(redirect_uris: [])

      signup_as "admin" do
        get "/authorize",
            params: {
              response_type: "code",
              client_id: client.key,
              redirect_uri: "https://example.com"
            }

        admin = Masks::Rails::Actor.find_by!(nickname: "admin")

        assert_authorization(admin)

        client.reload

        assert_equal ["https://example.com"], client.reload.redirect_uris
      end
    end

    test "GET authorize does not assign the first redirect_uri if the request is not approved" do
      client = add_client(redirect_uris: [])

      get "/authorize",
          params: {
            response_type: "code",
            client_id: client.key,
            redirect_uri: "https://example.com"
          }

      client.reload

      assert client.reload.redirect_uris.blank?
    end

    test "GET authorize redirects to login if not authenticated" do
      client = add_client

      get "/authorize",
          params: {
            response_type: "code",
            client_id: client.key,
            redirect_uri: "https://example.com"
          }

      assert_equal 302, status
      assert_includes headers["Location"], "/session"

      signup_as "admin"

      follow_redirect!

      admin = Masks::Rails::Actor.find_by!(nickname: "admin")

      assert_authorization(admin)
    end

    test "GET authorize redirects to the RP if already authenticated" do
      client = add_client

      signup_as "admin" do
        get "/authorize",
            params: {
              response_type: "code",
              client_id: client.key,
              redirect_uri: "https://example.com"
            }

        admin = Masks::Rails::Actor.find_by!(nickname: "admin")

        assert_authorization(admin)
      end
    end

    test "GET authorize creates authorization codes that can be exchanged for access tokens" do
      client = add_client
      redirect_uri = "https://example.com"
      authorization = nil
      admin = nil

      signup_as "admin" do
        get "/authorize",
            params: {
              response_type: "code",
              client_id: client.key,
              redirect_uri:
            }

        admin = Masks::Rails::Actor.find_by!(nickname: "admin")
        authorization = assert_authorization(admin)
      end

      post "/token",
           params: {
             client_id: client.key,
             client_secret: client.secret,
             grant_type: "authorization_code",
             code: authorization.code,
             redirect_uri:
           }

      token =
        Masks::Rails::OpenID::AccessToken.find_by!(
          actor: admin,
          openid_client: client
        )

      assert_equal 200, status
      assert_equal token.token, response.parsed_body["access_token"]
    end

    def assert_authorization(actor)
      authorization = Masks::Rails::OpenID::Authorization.find_by(actor:)

      assert_equal 302, status
      assert_includes headers["Location"],
                      "https://example.com?code=#{authorization.code}"

      authorization
    end
  end
end
