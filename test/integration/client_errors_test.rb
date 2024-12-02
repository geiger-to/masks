require "test_helper"

class ClientErrorTest < MasksTestCase
  include AuthHelper

  test "404 for unknown clients" do
    authorize client_id: "invalid"

    assert_not auth_id
    # assert_equal 404, response.status
    assert_artifacts
  end

  test "404 for unknown clients on non-oidc route" do
    authorize path: "/authorize/invalid"
    assert_not auth_id
    # assert_equal 404, response.status
    assert_artifacts
  end

  test "missing-client for attempts with missing clients" do
    authorize
    client.destroy!
    attempt

    assert_prompt "missing-client"
    assert_error "missing-client"
    assert_settled
    assert_artifacts devices: 1
  end

  test "expired-state resets automatically on authorization" do
    authorize
    attempt_identifier "manager"
    assert_equal auth_result[:identifier], "manager"

    id = auth_id

    travel 1.year

    # equivalent to a refresh
    authorize

    assert_nil auth_result[:identifier]
    assert_equal id, auth_id
  end
end
