class AuthorizeManagerTest < MasksTestCase
  include AuthorizeHelper

  PREFIX = %i[data authorize]

  def client_id
    Masks::Client::MANAGE_KEY
  end

  test_authorization path: "/authorize/manage", redirect_uri: "/manage"

  test "error for actors lacking appropriate scopes" do
    seeder.seed_actor(nickname: "test", password: "password")

    authorize

    assert_error_code "scopes_required",
                      attempt(identifier: "test", password: "password")
    assert_artifacts(devices: 1)
  end

  test "redirect to /manage on valid login, sans redirect_uri" do
    authorize

    assert_authorized attempt(identifier: "manager", password: "password"),
                      redirect_uri: "/manage"
    assert_artifacts(codes: 1, devices: 1)
  end

  test "deny is ignored for internal clients" do
    authorize

    assert_authorized attempt(
                        identifier: "manager",
                        password: "password",
                        deny: true,
                      ),
                      redirect_uri: "/manage"

    assert_artifacts(codes: 1, devices: 1)
  end
end
