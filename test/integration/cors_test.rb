require "test_helper"

class CorsTest < MasksTestCase
  test "CORS is enabled on the /graphql endpoint" do
    options "/graphql",
            headers: {
              Origin: Masks.url,
              "Access-Control-Request-Method": "POST",
            }

    assert_equal Masks.url, headers["Access-Control-Allow-Origin"]
  end
end
