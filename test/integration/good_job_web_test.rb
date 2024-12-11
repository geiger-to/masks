require "test_helper"

class GoodJobWebTest < MasksTestCase
  include AuthHelper

  setup do
    Masks.env.queue_adapter = :good_job
    Rails.application.reload_routes!
  end

  test "good_job-web is available to managers" do
    log_in "manager"

    get "/manage/queue"

    assert_equal 302, status
    assert_redirected_to "/manage/queue/jobs?locale=en"
  end

  test "good_job-web redirects to login for non-managers" do
    get "/manage/queue"

    assert_equal 302, status
  end
end
