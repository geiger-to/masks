require "test_helper"

module Masks
  class MiddlewareTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "anonymous routes (no checks, no creds)" do
      get "/anon"

      assert_equal 200, status
      assert_equal({ "anon" => true }, response.parsed_body)
    end

    test "public routes (no checks, creds specified)" do
      get "/public"

      assert_equal 200, status
      assert response.parsed_body["public"].start_with?("anon:")
    end

    def dummy_app?
      true
    end
  end
end
