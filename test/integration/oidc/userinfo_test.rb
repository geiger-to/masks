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

      signup_as nickname: "admin" do
        get "/authorize",
            params: {
              response_type: "token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = find_actor("@admin")
        token =
          Masks::Rails::OpenID::AccessToken.find_by!(
            actor: admin,
            openid_client: client
          )

        post "/userinfo", params: { access_token: token.token }

        assert_equal 200, status
        assert_equal({ "sub" => "@admin" }, response.parsed_body)
      end
    end

    test "POST /userinfo returns pairwise subjects" do
      client = add_client(client_type: "public", subject_type: "pairwise")

      signup_as nickname: "admin" do
        get "/authorize",
            params: {
              response_type: "token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = find_actor("@admin")
        admin.update_attribute(:uuid, '12345')
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
            "76cf21e9f269ef4910f14170bc88efb5233770c983ded132a38fc2f86e76958e"
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

      signup_as nickname: "admin" do
        get "/authorize",
            params: {
              response_type: "token",
              client_id: client.key,
              redirect_uri: "https://example.com",
              nonce: "12345"
            }

        admin = find_actor("@admin")
        admin.update_attribute(:uuid, '12345')
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
            "a3b3bc413ae15241f764fb6bb073a7af22b8aebdfff323aca13bd889d4dc6ce3"
          },
          response.parsed_body
        )
      end
    end
  end
end
