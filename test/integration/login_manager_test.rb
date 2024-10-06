class LoginManagerTest < MasksTestCase
  PREFIX = %i[data authorize]

  test "manage client is returned" do
    assert_equal Masks::Client::MANAGE_KEY,
                 authorize.parsed_body.dig(*PREFIX, :client, :id)
    assert_artifacts(devices: 1)
  end

  test "invalid credentials for unknown actors" do
    assert_equal "invalid_credentials",
                 authorize(nickname: "invalid", password: "").parsed_body.dig(
                   *PREFIX,
                   :errorCode,
                 )
    assert_equal "invalid credentials",
                 authorize(
                   nickname: "manager",
                   password: "bad",
                 ).parsed_body.dig(*PREFIX, :errorMessage)

    assert_authorized authorize(nickname: "manager", password: "password")

    assert_artifacts(devices: 1, codes: 1)
  end

  test "404 for unknown clients" do
    assert_equal 404, authorize(client_id: "invalid").status
    assert_artifacts
  end

  test "error for actors lacking appropriate scopes" do
    assert_error_code authorize(nickname: "test", password: "password"),
                      "scopes_required"
    assert_artifacts(devices: 1)
  end

  test "redirect to /manage on valid login, sans redirect_uri" do
    assert_authorized authorize(nickname: "manager", password: "password"),
                      redirect_uri: "http://example.com/manage"
    assert_artifacts(codes: 1, devices: 1)
  end

  test "internal sessions end after 12 hours" do
    freeze_time

    assert_authorized authorize(nickname: "manager", password: "password"),
                      redirect_uri: "http://example.com/manage"

    travel 11.hours do
      assert_logged_in :get, "/manage"
    end

    travel (12.hours + 1.second) do
      refute_logged_in :get, "/manage"
    end

    assert_artifacts(codes: 1, devices: 1)
  end

  test "internal sessions end after client#code_expires_in" do
    freeze_time

    seeder.manage_client.update_attribute(:code_expires_in, "1 day")

    assert_authorized authorize(nickname: "manager", password: "password"),
                      redirect_uri: "http://example.com/manage"

    travel 23.hours do
      assert_logged_in :get, "/manage"
    end

    travel (24.hours + 1.second) do
      refute_logged_in :get, "/manage"
    end

    assert_artifacts(codes: 1, devices: 1)
  end

  test "deny is ignored for internal clients" do
    assert_authorized authorize(
                        nickname: "manager",
                        password: "password",
                        deny: true,
                      ),
                      redirect_uri: "http://example.com/manage"

    assert_artifacts(codes: 1, devices: 1)
  end

  def assert_artifacts(devices: 0, tokens: 0, jwts: 0, codes: 0)
    assert_equal codes, Masks::AuthorizationCode.count
    assert_equal devices, Masks::Device.count
    assert_equal tokens, Masks::AccessToken.count
    assert_equal jwts, Masks::IdToken.count
  end
end
