require "test_helper"

class LoginLinksTest < MasksTestCase
  include AuthHelper

  test "login-link:password switches to password entry" do
    authorize
    attempt_identifier("foobar")
    attempt event: "login-link:authenticate"
    assert_prompt "login-code"
    attempt event: "login-link:password"
    assert_prompt "credentials"
  end

  test "login-link:authenticate sends an email" do
    authorize
    attempt_identifier("manager")
    attempt event: "login-link:authenticate"

    perform_enqueued_jobs
    assert_emails 1
    assert_prompt "login-code"
  end

  test "login-link:authenticate does not send duplicate emails" do
    authorize
    attempt_identifier("manager")

    attempt event: "login-link:authenticate"
    attempt event: "login-link:authenticate"

    perform_enqueued_jobs
    assert_emails 1
    assert_prompt "login-code"
  end

  test "login-link:authenticate does not send emails to invalid addresses" do
    authorize
    attempt_identifier("invalid@example.com")

    attempt event: "login-link:authenticate"

    assert Masks::LoginLink.none?

    perform_enqueued_jobs
    assert_emails 0
    assert_prompt "login-code"
  end

  test "login-link:authenticate does not send emails to actors with no address" do
    manager.emails.destroy_all

    authorize
    attempt_identifier("manager")

    attempt event: "login-link:authenticate"

    assert Masks::LoginLink.none?

    perform_enqueued_jobs
    assert_emails 0
    assert_prompt "login-code"
  end

  test "login-link:authenticate uses the identifier to pick the email address" do
    address = "masks@example.com"
    email = manager.emails.for_login.find_by(address:)
    manager.emails.build(address: "another@example.com").for_login.save!

    authorize
    attempt_identifier("manager")

    attempt event: "login-link:authenticate"

    attempt_identifier(address)

    attempt event: "login-link:authenticate"

    assert email.login_links.for_login.one?

    perform_enqueued_jobs
    assert_emails 1
    assert_prompt "login-code"
  end

  test "login-link:verify authenticates given a valid code" do
    authorize
    attempt_identifier("manager")

    attempt event: "login-link:authenticate"

    link = manager.login_email.login_links.for_login.active.first

    attempt event: "login-link:verify", updates: { code: link.code }

    assert_login
  end

  test "login-link:verify authenticates given a valid code over GET params" do
    authorize
    attempt_identifier("manager")
    attempt event: "login-link:authenticate"
    link = manager.login_email.login_links.for_login.active.first

    attempt event: "login-link:verify", updates: { login_code: "invalid" }
    refute_settled

    attempt event: "login-link:verify", params: { login_code: link.code }
    assert_login
  end
end
