class AuthorizePublicTokenTest < MasksTestCase
  include AuthorizeHelper

  def client
    @client ||=
      Masks::Client.create!(
        name: "test",
        client_type: "public",
        redirect_uris: "http://example.com/test",
        consent: true,
      )
  end

  def client_id
    client.key
  end

  test_authorization response_type: "token",
                     nonce: SecureRandom.uuid,
                     redirect_uri: "http://example.com/test"
end
