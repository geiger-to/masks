require "test_helper"

class PublicTokenConsentTest < ClientTestCase
  test_client redirect_uri: "https://example.com",
              response_type: "token",
              nonce: SecureRandom.uuid

  def client
    @client ||=
      Masks::Client
        .create!(
          key: "testing",
          name: "testing",
          client_type: "public",
          redirect_uris: "https://example.com",
        )
        .tap { |c| c.add_check! "client-consent" }
  end
end
