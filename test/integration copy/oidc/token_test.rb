# frozen_string_literal: true

require "test_helper"

module Masks
  # API requests are enabled via an Authorization header
  class TokenTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "POST /token requires a valid client id" do
      post "/token",
           params: {
             grant_type: "client_credentials",
             client_id: "invalid",
             client_secret: "invalid"
           }

      assert_equal 401, status
    end

    test "POST /token requires a valid client secret" do
      client = add_client

      post "/token",
           params: {
             grant_type: "client_credentials",
             client_id: client.key,
             client_secret: "invalid"
           }

      assert_equal 401, status
    end

    test "POST /token issues access_tokens to confidential clients" do
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

      assert_equal token.token, response.parsed_body["access_token"]
      assert_equal 200, status
    end

    test "POST /token does not issue client_credentials to public clients" do
      client = add_client(client_type: "public")

      post "/token",
           params: {
             grant_type: "client_credentials",
             client_id: client.key,
             client_secret: client.secret
           }

      assert_equal 400, status
    end
  end
end
