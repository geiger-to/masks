require "test_helper"

class ConfidentialCodeTest < ClientTestCase
  test_client redirect_uri: "https://example.com", response_type: "code"

  def client
    @client ||=
      seeder.seed_client(
        key: "testing",
        name: "testing",
        type: "confidential",
        redirect_uris: "https://example.com",
      )
  end
end
