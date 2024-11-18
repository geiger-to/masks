require "test_helper"

class OnboardingTest < MasksTestCase
  include AuthHelper

  setup { client.add_check! "onboarded" }

  test "onboarding is not required when the check is missing" do
    client.remove_check! "onboarded"

    log_in "manager"

    assert_login
  end

  test "onboarding is required when the check is present" do
    log_in "manager"

    assert_prompt "onboard"

    refute_settled

    attempt event: "onboard:confirm"

    assert_login
  end

  test "onboarding allows changing name and password" do
    log_in "manager"

    attempt event: "onboard:profile",
            updates: {
              name: "tester",
              password: "testing123",
            }

    assert_equal "tester", seeder.manager.reload.name
    assert seeder.manager.authenticate("testing123")
    assert_not seeder.manager.authenticate("password")
  end

  test "onboarding allows password changes after a cooldown period" do
    log_in "manager"

    attempt event: "onboard:profile", updates: { password: "testing123" }
    attempt event: "onboard:profile", updates: { password: "testing456" }

    assert seeder.manager.reload.authenticate("testing123")

    travel ChronicDuration.parse(Masks.setting(:password, :change_cooldown))
    travel 1.second

    attempt event: "onboard:profile", updates: { password: "testing456" }

    assert seeder.manager.reload.authenticate("testing456")
  end

  test "onboarding allows adding login emails" do
    email = "testing@example.com"

    log_in "manager"

    assert_not seeder.manager.emails.for_login.find_by(address: email)

    attempt event: "onboard-email:add", updates: { email: }

    assert seeder.manager.emails.for_login.find_by(address: email)
  end

  test "onboarding warns when adding invalid emails" do
    address = "invalid"

    log_in "manager"

    attempt event: "onboard-email:add", updates: { email: address }

    assert_warning "invalid-email:#{address}"
  end

  test "onboard-email:verify does not send duplicates" do
    address = "masks@example.com"

    log_in "manager"

    email = seeder.manager.emails.for_login.find_by(address:)

    attempt event: "onboard-email:verify", updates: { email: address }
    attempt event: "onboard-email:verify", updates: { email: address }

    assert_equal 1, email.login_links.active.for_verification.count
    perform_enqueued_jobs
    assert_emails 1
  end

  test "onboard-email:verify-code verifies login emails" do
    address = "masks@example.com"

    log_in "manager"

    email = seeder.manager.emails.for_login.find_by(address:)
    assert_not email.verified?

    assert_equal 0, email.login_links.active.for_verification.count

    attempt event: "onboard-email:verify", updates: { email: address }

    assert_equal 1, email.login_links.active.for_verification.count

    link = email.login_links.active.for_verification.first

    attempt event: "onboard-email:verify-code",
            updates: {
              code: link.code,
              email: address,
            }

    assert email.reload.verified?
  end

  test "onboard-email:verify-code rejects invalid codes" do
    address = "masks@example.com"

    log_in "manager"

    attempt event: "onboard-email:verify", updates: { email: address }
    attempt event: "onboard-email:verify-code",
            updates: {
              code: "invalid",
              email: address,
            }

    email = seeder.manager.emails.for_login.find_by(address:)

    assert_warning "invalid-code:invalid"

    assert_not email.reload.verified?
  end
end
