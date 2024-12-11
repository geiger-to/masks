require "test_helper"

class VerifiedEmailTest < MasksTestCase
  include AuthHelper

  setup { client.add_check!("verified-email") }

  test "verified emails are not required when the check is disabled" do
    client.remove_check!("verified-email")

    log_in "manager"

    assert_login
  end

  test "verified emails are required when the check is enabled" do
    log_in "manager"

    assert_prompt "verify-email"

    refute_settled

    address = "masks@example.com"

    attempt event: "verified-email:verify", updates: { email: address }

    refute_settled

    link =
      manager
        .emails
        .for_login
        .find_by!(address:)
        .login_links
        .active
        .for_verification
        .first

    attempt event: "verified-email:verify-code",
            updates: {
              email: address,
              code: link.code,
            }

    assert_login
  end

  test "verified-email:verify-code rejects invalid codes" do
    log_in "manager"

    address = "masks@example.com"

    attempt event: "verified-email:verify", updates: { email: address }
    attempt event: "verified-email:verify-code",
            updates: {
              email: address,
              code: "invalid",
            }

    refute_settled
  end

  test "verify-email:add adds emails when none exist" do
    manager.emails.destroy_all

    log_in "manager"

    assert_prompt "verify-email"

    attempt event: "verified-email:add",
            updates: {
              email: "testing@example.com",
            }

    assert manager.emails.for_login.count
  end

  test "verify-email:add does not add existing emails" do
    manager.emails.destroy_all

    log_in "manager"

    assert_prompt "verify-email"

    attempt event: "verified-email:add", updates: { email: "test@example.com" }

    assert manager.reload.emails.none?
  end

  test "verify-email:add does not add invalid emails" do
    manager.emails.destroy_all

    log_in "manager"

    assert_prompt "verify-email"

    attempt event: "verified-email:add", updates: { email: "invalid" }

    assert manager.reload.emails.none?
  end
end
