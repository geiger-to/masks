require "test_helper"

class SidekiqWebTest < MasksTestCase
  include AuthHelper

  setup { Masks.env.queue_adapter = :sidekiq }

  test "sidekiq-web is available to managers" do
    log_in "manager"

    get "/manage/jobs"

    assert_equal 200, status
  end

  test "sidekiq-web redirects to login for non-managers" do
    get "/manage/jobs"

    assert_equal 302, status
  end
end
