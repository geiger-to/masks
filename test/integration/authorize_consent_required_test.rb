class AuthorizeConsentRequiredTest < MasksTestCase
  include AuthorizeHelper

  def client
    @client ||=
      Masks::Client.create!(
        name: "test",
        client_type: "confidential",
        redirect_uris: "http://example.com/test",
        consent: true,
      )
  end

  def client_id
    client.key
  end

  test_authorization response_type: "code",
                     redirect_uri: "http://example.com/test"

  test "prompt=authorize when approval is required" do
    authorize
    attempt nickname: "manager", password: "password"

    assert_equal "authorize", authorize_result["prompt"]

    refute_authorized
    assert_authenticated
  end

  test "denial redirects back with an error parameter" do
    authorize
    attempt nickname: "manager", password: "password", deny: true
    assert_includes authorize_result["redirectUri"], "http://example.com/test"
    assert_includes authorize_result["redirectUri"], "error=access_denied"
  end

  test "approval redirects back with an authorization code" do
    authorize
    attempt nickname: "manager", password: "password", approve: true
    assert_includes authorize_result["redirectUri"], "http://example.com/test"
    assert_includes authorize_result["redirectUri"], "code="
  end
end
