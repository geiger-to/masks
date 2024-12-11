require "test_helper"

class InternalClientTest < ClientTestCase
  test_client path: "/authorize/testing.json", redirect_uri: "/foobar"

  def client
    @client ||=
      Masks::Client.create!(
        key: "testing",
        name: "testing",
        client_type: "internal",
        redirect_uris: "/foobar",
      )
  end
end
