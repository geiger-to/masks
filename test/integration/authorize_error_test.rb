class AuthorizeErrorTest < MasksTestCase
  include AuthorizeHelper

  test "404 for unknown clients" do
    authorize client_id: "invalid"
    refute auth_id
    assert_equal 404, response.status
    assert_artifacts
  end

  test "404 for unknown clients on non-oidc route" do
    authorize path: "/authorize/invalid"
    refute auth_id
    assert_equal 404, response.status
    assert_artifacts
  end
end
