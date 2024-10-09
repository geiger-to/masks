class AuthorizeManagerTest < MasksTestCase
  include AuthorizeHelper

  PREFIX = %i[data authorize]

  def client_id
    Masks::Client::MANAGE_KEY
  end

  test_authorization path: "/authorize/manage", redirect_uri: "/manage"

  test "error for actors lacking appropriate scopes" do
    authorize path: "/authorize/manage"

    assert_error_code "scopes_required",
                      attempt(nickname: "test", password: "password")
    assert_artifacts(devices: 1)
  end

  test "redirect to /manage on valid login, sans redirect_uri" do
    authorize path: "/authorize/manage"

    assert_authorized attempt(nickname: "manager", password: "password"),
                      redirect_uri: "/manage"
    assert_artifacts(codes: 1, devices: 1)
  end

  test "deny is ignored for internal clients" do
    authorize path: "/authorize/manage"

    assert_authorized attempt(
                        nickname: "manager",
                        password: "password",
                        deny: true,
                      ),
                      redirect_uri: "/manage"

    assert_artifacts(codes: 1, devices: 1)
  end
end
