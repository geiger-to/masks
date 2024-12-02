require "test_helper"

class IdentifierTest < MasksTestCase
  include AuthHelper

  test "authorize returns a nil identifier by default" do
    authorize

    assert_prompt "identify"
    assert_nil auth_result[:identifier]
    assert_artifacts devices: 1
  end

  test "attempts with invalid nicknames return a warning" do
    identify('!@#$%^&*()')

    assert_prompt "identify"
    assert_nil auth_result[:identifier]
    assert_warning "invalid-identifier"
    assert_artifacts devices: 1
  end

  test "attempts to identify with a non-existent nickname moves to next prompt" do
    log_in("foobar")

    refute_prompt "identify"
    assert_equal "foobar", auth_result[:identifier]
    assert_artifacts devices: 1
  end

  test "attempts to identify with a non-existent email moves to next prompt" do
    log_in("foobar@example.com")

    refute_prompt "identify"
    assert_equal "foobar@example.com", auth_result[:identifier]
    assert_artifacts devices: 1
  end

  test "nickname identifiers are ignored when the feature is disabled" do
    Masks.installation.modify!(nicknames: { enabled: false })

    identify("manager")

    assert_prompt "identify"
    assert_nil auth_result[:identifier]
    assert_warning "invalid-identifier"
    assert_artifacts devices: 1
  end

  test "email identifiers are ignored when the feature is disabled" do
    Masks.installation.modify!(emails: { enabled: false })

    identify("masks@example.com")

    assert_prompt "identify"
    assert_nil auth_result[:identifier]
    assert_warning "invalid-identifier"
    assert_artifacts devices: 1
  end

  test "emails from the 'login' group are valid identifiers" do
    assert_login log_in("masks@example.com")
    assert_artifacts devices: 1
  end

  test "nicknames are valid identifiers" do
    assert_login log_in("manager")
    assert_artifacts devices: 1
  end

  test "only emails from the 'login' group are valid identifiers" do
    email = "masks@example.com"
    seeder
      .manager
      .emails
      .for_login
      .find_by!(address: email)
      .update_attribute("group", "test")

    log_in(email)

    refute_settled
  end

  private

  def identify(id)
    authorize
    refute_error
    attempt_identifier(id)
    refute_error
  end
end
