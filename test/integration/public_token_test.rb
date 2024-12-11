require "test_helper"

class PublicTokenTest < ClientTestCase
  test_client redirect_uri: "https://example.com",
              response_type: "token",
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
end
