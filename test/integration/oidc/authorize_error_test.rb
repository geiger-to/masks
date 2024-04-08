# frozen_string_literal: true

require "test_helper"

module Masks
  # API requests are enabled via an Authorization header
  class AuthorizeErrorTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET authorize requires a client id" do
      get "/authorize"

      assert_equal 400, status
    end

    test "GET authorize requires a response_type" do
      client = add_client

      get "/authorize",
          params: {
            client_id: client.key,
            redirect_uri: "https://example.com"
          }

      assert_equal 400, status
    end

    test "GET authorize requires a redirect_uri" do
      client = add_client

      get "/authorize", params: { response_type: "code", client_id: client.key }

      assert_equal 400, status
    end

    test "GET authorize requires a valid redirect_uri" do
      client = add_client

      get "/authorize",
          params: {
            response_type: "code",
            client_id: client.key,
            redirect_uri: "https://fake.example.com"
          }

      assert_equal 400, status
    end

    test "GET authorize requires a client that supports response_type=code " do
      client = add_client(client_type: "public")

      get "/authorize",
          params: {
            response_type: "code",
            client_id: client.key,
            redirect_uri: "https://example.com"
          }

      assert_equal 302, status
      assert_includes headers["Location"], "error=unsupported_response_type"
    end
    test "GET authorize requires a client that supports response_type=token" do
      client = add_client

      get "/authorize",
          params: {
            response_type: "token",
            client_id: client.key,
            redirect_uri: "https://example.com",
            nonce: "12345"
          }

      assert_equal 302, status
      assert_includes headers["Location"], "error=unsupported_response_type"
    end

    test "GET authorize response_type=token requires a nonce" do
      client = add_client

      get "/authorize",
          params: {
            response_type: "token",
            client_id: client.key,
            redirect_uri: "https://example.com"
          }

      assert_equal 302, status
      assert_includes headers["Location"], "error=invalid_request"
    end

    test "GET authorize requires a client that supports response_type=id_token" do
      client = add_client

      get "/authorize",
          params: {
            response_type: "id_token",
            client_id: client.key,
            redirect_uri: "https://example.com",
            nonce: "12345"
          }

      assert_equal 302, status
      assert_includes headers["Location"], "error=unsupported_response_type"
    end

    test "GET authorize response_type=id_token requires a nonce" do
      client = add_client

      get "/authorize",
          params: {
            response_type: "token",
            client_id: client.key,
            redirect_uri: "https://example.com"
          }

      assert_equal 302, status
      assert_includes headers["Location"], "error=invalid_request"
    end

    test "GET authorize requires a valid response_type" do
      client = add_client

      get "/authorize",
          params: {
            response_type: "invalid",
            client_id: client.key,
            redirect_uri: "https://example.com"
          }

      assert_equal 400, status
    end
  end
end
