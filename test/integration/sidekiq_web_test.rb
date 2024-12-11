require "test_helper"

class SidekiqWebTest < MasksTestCase
  include AuthHelper

  test "/sidekiq is available to managers" do
    log_in "manager"

    get "/sidekiq"

    assert_equal 200, status
  end

  test "/sidekiq 404s for non-managers" do
    get "/sidekiq"

    assert_equal 404, status
  end
end
