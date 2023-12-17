require "test_helper"

module Masks
  # [GET|POST] /session
  #
  # browsers are redirected automatically instead of
  # displaying a response in typical authentication flows.
  #
  # in the most common case the browser is redirected to '/'
  # after authentication and back to login on failure.
  class RedirectsTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "GET /recovery while authenticated redirects away" do
      signup_as "admin"
      get "/recover"
      follow_redirect!
      assert_equal "/", request.path
    end

    test "POST /session failed signups redirect to /session" do
      signup_as "fail"
      follow_redirect!

      assert_equal "/session", request.path
      refute_logged_in
    end

    test "POST /session signups redirect to /" do
      signup_as "admin"
      follow_redirect!

      assert_equal "/", request.path
      assert_logged_in
    end
  end
end
