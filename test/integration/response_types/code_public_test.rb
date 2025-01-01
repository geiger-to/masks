require "test_helper"

class ResponseTypeCodePublicTest < ClientTestCase
  test_client redirect_uri: "https://example.com",
              response_type: "code",
              code_challenge: SecureRandom.uuid,
              code_challenge_method: "plain",
              nonce: SecureRandom.uuid

  def client
    @client ||=
      Masks::Client.create!(
        key: "testing",
        name: "testing",
        client_type: "public",
        redirect_uris: "https://example.com",
      )
  end

  test "unsupported response_types return an error" do
    authorize(response_type: "invalid")
    assert_error "invalid-response"
    assert_prompt "invalid-response"
    assert_settled
    assert_artifacts
  end

  test "pkce method=S256 is accepted" do
    freeze_time

    authorize(response_type: "code", code_challenge_method: "S256")

    assert_prompt "identify"
  end

  test "invalid pkce methods return an error" do
    freeze_time

    authorize(response_type: "code", code_challenge_method: "invalid")

    assert_error "invalid-pkce"
    assert_prompt "invalid-pkce"
    assert_settled
    assert_artifacts
  end

  test "authorization codes can be exchanged for access tokens" do
    freeze_time

    log_in "manager"

    secret = assert_redirect_uri.dig("params", "code")

    assert_token secret:, type: "Masks::AuthorizationCode"

    post "/token",
         params: {
           grant_type: "authorization_code",
           client_id: client.key,
           client_secret: client.secret,
           redirect_uri: "https://example.com",
           code_verifier: self.class.auth_opts[:code_challenge],
           code: secret,
         }

    assert_equal 200, status

    token = response.parsed_body["access_token"]

    assert_token secret: token, type: "Masks::AccessToken"
    assert_equal "bearer", response.parsed_body["token_type"]
    assert_equal 21_600, response.parsed_body["expires_in"]
  end

  test "empty code_challenge redirects back with error" do
    freeze_time

    authorize(response_type: "code", code_challenge: "")

    assert_error "invalid-pkce"
    assert_prompt "invalid-pkce"
    assert_settled
    assert_artifacts
  end

  test "pkce is required to exchange codes for access tokens" do
    log_in "manager"

    secret = assert_redirect_uri.dig("params", "code")

    assert_token secret:, type: "Masks::AuthorizationCode"

    post "/token",
         params: {
           grant_type: "authorization_code",
           client_id: client.key,
           client_secret: client.secret,
           redirect_uri: "https://example.com",
           code: secret,
         }

    assert_equal 400, status

    assert_equal "invalid_grant", response.parsed_body["error"]
  end
end
