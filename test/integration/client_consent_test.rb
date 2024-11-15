require "test_helper"

class ClientConsentTest < MasksTestCase
  include AuthHelper

  setup { client.add_check!("client-consent") }

  test "client consent must be approved" do
    log_in "manager"

    assert_prompt "authorize"
    refute_settled
    assert_login attempt(event: "authorize")
  end

  test "client consent can be denied" do
    log_in "manager"
    attempt event: "deny"

    assert_settled
    assert_error "access-denied"
    assert_includes auth_result[:redirectUri], "error=access_denied"
    refute_includes auth_result[:redirectUri], "code="
  end
end
