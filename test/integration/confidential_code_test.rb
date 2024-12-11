require "test_helper"

class ConfidentialCodeTest < ClientTestCase
  test_client redirect_uri: "https://example.com", response_type: "code"

  def client
    @client ||=
      Masks::Client.create!(
        key: "testing",
        name: "testing",
        client_type: "confidential",
        redirect_uris: "https://example.com",
      )
  end
end
