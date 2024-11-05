require "test_helper"

class ResetPasswordTest < MasksTestCase
  include AuthorizationHelper

  test "login-link:verify allows prompting for reset password" do
    log_in_via_link(manager)

    assert_prompt "reset-password"
  end

  test "reset-password event resets password" do
    log_in_via_link(manager)

    attempt event: "reset-password", updates: { newPassword: "testing123" }

    assert_prompt "reset-password"
  end

  private

  def log_in_via_link(actor)
    authorize
    attempt_identifier(actor.identifier)
    attempt event: "login-link:authenticate"

    link = actor.login_email.login_links.for_login.active.first

    attempt event: "login-link:verify",
            updates: {
              code: link.code,
              resetPassword: true,
            }
  end
end
