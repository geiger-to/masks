require "test_helper"

class InternalClientTest < ClientTestCase
  test_client path: "/authorize/testing.json", redirect_uri: "/foobar"

  def client
    @client ||=
      seeder.seed_client(
        key: "testing",
        name: "testing",
        type: "internal",
        redirect_uris: "/foobar",
      )
  end
end