require "test_helper"

class PasswordTest < MasksTestCase
  include AuthHelper

  test "credential prompt is shown after an identifier is added" do
    authorize
    attempt_identifier("manager")

    assert_prompt "credentials"
  end

  test "password:verify rejects invalid passwords" do
    authorize
    attempt_identifier("manager")
    attempt_password("invalid")

    assert_warning "invalid-credentials"
    assert_prompt "credentials"
  end

  test "password:verify rejects passwords for actors with nil passwords" do
    Masks.signup("no-password").save!

    authorize
    attempt_identifier("no-password")
    attempt_password("invalid")

    assert_warning "invalid-credentials"
    assert_prompt "credentials"
  end

  test "password:verify rejects invalid passwords for invalid actors" do
    authorize
    attempt_identifier("invalid")
    attempt_password("invalid")

    assert_warning "invalid-credentials"
    assert_prompt "credentials"
  end

  test "password:verify authenticates valid passwords" do
    log_in "manager"

    assert_login
  end
end
