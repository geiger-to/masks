class AuthorizeConfidentialCodeTest < MasksTestCase
  include AuthorizeHelper

  def client
    @client ||=
      Masks::Client.create!(
        name: "test",
        client_type: "confidential",
        redirect_uris: "http://example.com/test",
        consent: false,
      )
  end

  def client_id
    client.key
  end

  test_authorization response_type: "code",
                     redirect_uri: "http://example.com/test"
end
