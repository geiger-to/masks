require "test_helper"

class SidekiqWebTest < MasksTestCase
  include AuthHelper

  setup do
    Masks.env.queue_adapter = :sidekiq
    Rails.application.reload_routes!
  end

  test "sidekiq-web is available to managers" do
    log_in "manager"

    get "/manage/queue"

    assert_equal 200, status
    assert_includes response.body, "<title>[TEST] Sidekiq</title>"
  end

  test "sidekiq-web redirects to login for non-managers" do
    get "/manage/queue"

    assert_equal 302, status
  end
end
