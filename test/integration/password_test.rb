require "test_helper"

class PasswordTest < MasksTestCase
  include AuthorizationHelper

  test "credential prompt is shown after an identifier is added" do
    authorize
    attempt_identifier("manager")

    assert_prompt "credential"
  end

  test "password:check rejects invalid passwords" do
    authorize
    attempt_identifier("manager")
    attempt_password("invalid")

    assert_warning "invalid-credentials"
    assert_prompt "credential"
  end

  test "password:check rejects invalid passwords for invalid actors" do
    authorize
    attempt_identifier("invalid")
    attempt_password("invalid")

    assert_warning "invalid-credentials"
    assert_prompt "credential"
  end

  test "password:check authenticates valid passwords" do
    log_in "manager"

    assert_authorized
  end
end
