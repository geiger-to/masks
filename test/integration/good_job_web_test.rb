require "test_helper"

class GoodJobWebTest < MasksTestCase
  include AuthHelper

  setup { use_good_job }

  test "good_job-web is available to managers" do
    use_good_job

    log_in "manager"

    get "/manage/queue"

    assert_equal 302, status
    assert_redirected_to "/manage/queue/jobs?locale=en"
  end

  test "good_job-web redirects to login for non-managers" do
    use_good_job

    get "/manage/queue"

    assert_includes [404, 302], status
  end

  def use_good_job
    Masks.env.queue_adapter = :good_job
    Rails.application.reload_routes!
  end
end
