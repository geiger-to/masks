# frozen_string_literal: true

require "test_helper"

module Masks
  # API requests are enabled via an Authorization header
  class UserInfoTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "POST /userinfo requires a valid access token" do
      post "/userinfo"

      assert_equal 401, status
    end

    test "POST /userinfo does not accept client_credentials access tokens" do
      client = add_client

      post "/token",
           params: {
             grant_type: "client_credentials",
             client_id: client.key,
             client_secret: client.secret
           }

      token =
        Masks::Rails::OpenID::AccessToken.find_by!(
          openid_client: client,
          actor: nil
        )

      post "/userinfo", params: { access_token: token.token }

      assert_equal 401, status
    end

    test "POST /userinfo accepts access tokens for actors" do
      client = add_client(client_type: "public")

      signup_as "admin" do
        get "/authorize",
            params: {
              response_type: "token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = Masks::Rails::Actor.find_by!(nickname: "admin")
        token =
          Masks::Rails::OpenID::AccessToken.find_by!(
            actor: admin,
            openid_client: client
          )

        post "/userinfo", params: { access_token: token.token }

        assert_equal 200, status
        assert_equal({ "sub" => "admin" }, response.parsed_body)
      end
    end

    test "POST /userinfo returns pairwise subjects" do
      client = add_client(client_type: "public", subject_type: "pairwise")

      signup_as "admin" do
        get "/authorize",
            params: {
              response_type: "token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = Masks::Rails::Actor.find_by!(nickname: "admin")
        token =
          Masks::Rails::OpenID::AccessToken.find_by!(
            actor: admin,
            openid_client: client
          )

        post "/userinfo", params: { access_token: token.token }

        assert_equal 200, status
        assert_equal(
          {
            "sub" =>
              "4f1bf395fb5f2a4596f174edca6caeb89d33e75b2c19f81600c05fb0be2d5925"
          },
          response.parsed_body
        )
      end
    end

    test "POST /userinfo returns pairwise subjects with a custom sector_identifier" do
      client =
        add_client(
          client_type: "public",
          subject_type: "pairwise",
          sector_identifier: "example.com"
        )

      signup_as "admin" do
        get "/authorize",
            params: {
              response_type: "token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = Masks::Rails::Actor.find_by!(nickname: "admin")
        token =
          Masks::Rails::OpenID::AccessToken.find_by!(
            actor: admin,
            openid_client: client
          )

        post "/userinfo", params: { access_token: token.token }

        assert_equal 200, status
        assert_equal(
          {
            "sub" =>
              "c72360bf19ea6ce4011b1df9e6332856f131702e6854117382aee1eb745885a3"
          },
          response.parsed_body
        )
      end
    end
  end
end
