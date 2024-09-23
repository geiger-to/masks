# frozen_string_literal: true

require "test_helper"

module Masks
  # API requests are enabled via an Authorization header
  class DiscoveryTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /client/:id/.well-known/openid-configuration requires a valid client id" do
      get "/client/invalid/.well-known/openid-configuration"

      assert_equal 404, status
    end

    test "GET /client/:id/.well-known/openid-configuration returns discovery details for confidential clients" do
      client = add_client

      get "/client/#{client.key}/.well-known/openid-configuration"

      json = {
        "issuer" => "http://localhost:3000/client/test",
        "authorization_endpoint" => "http://www.example.com/authorize",
        "jwks_uri" => "http://www.example.com/client/test/jwks.json",
        "response_types_supported" => ["code"],
        "subject_types_supported" => ["public"],
        "id_token_signing_alg_values_supported" => ["RS256"],
        "token_endpoint" => "http://www.example.com/token",
        "userinfo_endpoint" => "http://www.example.com/userinfo",
        "scopes_supported" => %w[openid profile email address phone],
        "grant_types_supported" => %w[
          refresh_token
          authorization_code
          client_credentials
        ],
        "token_endpoint_auth_methods_supported" => %w[
          client_secret_basic
          client_secret_post
        ],
        "claims_supported" => %w[sub iss name email address phone_number],
        "claims_parameter_supported" => false,
        "request_parameter_supported" => false,
        "request_uri_parameter_supported" => false
      }

      assert_equal 200, status
      assert_equal json, response.parsed_body
    end

    test "GET /client/:id/.well-known/openid-configuration returns discovery details for public clients" do
      client = add_client(client_type: "public")

      get "/client/#{client.key}/.well-known/openid-configuration"

      json = {
        "issuer" => "http://localhost:3000/client/test",
        "authorization_endpoint" => "http://www.example.com/authorize",
        "jwks_uri" => "http://www.example.com/client/test/jwks.json",
        "response_types_supported" => ["token", "id_token", "id_token token"],
        "subject_types_supported" => ["public"],
        "id_token_signing_alg_values_supported" => ["RS256"],
        "token_endpoint" => "http://www.example.com/token",
        "userinfo_endpoint" => "http://www.example.com/userinfo",
        "scopes_supported" => %w[openid profile email address phone],
        "grant_types_supported" => [],
        "token_endpoint_auth_methods_supported" => %w[
          client_secret_basic
          client_secret_post
        ],
        "claims_supported" => %w[sub iss name email address phone_number],
        "claims_parameter_supported" => false,
        "request_parameter_supported" => false,
        "request_uri_parameter_supported" => false
      }

      assert_equal 200, status
      assert_equal json, response.parsed_body
    end

    test "GET /client/:id/jwks.json returns the client's public key" do
      client = add_client

      get "/client/#{client.key}/jwks.json"

      json = response.parsed_body.symbolize_keys
      jwks = JSON::JWK::Set.new(json[:keys])

      assert_equal 200, status
      assert_equal json, jwks.as_json
    end

    test "GET /client/:id/jwks.json returns different keys for different clients" do
      client1 = add_client(name: "test1")
      client2 = add_client(name: "test2")

      get "/client/#{client1.key}/jwks.json"
      json1 = response.parsed_body.deep_symbolize_keys

      get "/client/#{client2.key}/jwks.json"
      json2 = response.parsed_body.deep_symbolize_keys

      refute_equal json1, json2
    end
  end
end
