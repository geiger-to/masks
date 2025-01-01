require "test_helper"

class ResponseTypeIdTokenTest < ClientTestCase
  test_client redirect_uri: "https://example.com",
              response_type: "id_token",
              nonce: SecureRandom.uuid

  def client
    @client ||=
      Masks::Client.create!(
        key: "testing",
        name: "testing",
        client_type: "public",
        redirect_uris: "https://example.com",
        response_types: ["id_token"],
      )
  end

  test "nonces are required" do
    authorize(nonce: "")

    assert_prompt "missing-nonce"
    assert_error "missing-nonce"
    assert_settled
  end

  test "unsupported response_types return an error" do
    authorize(response_type: "code")
    assert_error "invalid-response"
    assert_prompt "invalid-response"
    assert_settled
    assert_artifacts
  end

  test "access_tokens are returned in the uri" do
    freeze_time

    log_in "manager"

    redirect = assert_redirect_uri

    assert redirect.dig("fragment", "id_token")
  end
end
