class MasksTestCase < ActionDispatch::IntegrationTest
  def user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"
  end

  def seeder
    @seeder ||= Masks::Seeder.new
  end

  def client_id
    Masks::Client::MANAGE_KEY
  end

  setup do
    Masks.url = "http://example.com"
    Masks.reset!
    Masks.install!
    seeder.seed_env!
  end

  def assert_error_code(response, code)
    assert_equal code, response.parsed_body.dig(:data, :authorize, :errorCode)
  end

  def assert_authorized(response, redirect_uri: nil)
    data = response.parsed_body.dig(:data, :authorize) || {}
    assert data.dig(:redirectUri)
    assert_equal redirect_uri, data.dig(:redirectUri) if redirect_uri
    assert data.dig(:authenticated)
    assert data.dig(:authorized)
    assert data.dig(:client)
    refute data.dig(:errorCode)
    refute data.dig(:errorMessage)
  end

  def assert_logged_in(method, path)
    send(method, path)
    refute_equal 302, status
  end

  def refute_logged_in(method, path)
    send(method, path)
    assert_equal 302, status
  end

  def authorize(**vars)
    get "/authorize/#{vars.delete(:client_id) || client_id}"

    auth_id = response.headers["X-Masks-Auth-Id"]

    return response unless auth_id

    query = <<-GQL
        mutation ($input: AuthorizeInput!) {
          authorize(input: $input) {
            errorMessage
            errorCode
            nickname
            authenticated
            authorized
            redirectUri
            client {
              id
              name
            }
          }
        }
      GQL

    post "/graphql",
         as: :json,
         params: {
           query:,
           variables: {
             input: {
               id: auth_id,
               **vars,
             },
           },
         }

    response
  end

  def get(*args, **opts)
    super(*args, **opts.merge(headers: { "HTTP_USER_AGENT" => user_agent }))
  end

  def post(*args, **opts)
    super(*args, **opts.merge(headers: { "HTTP_USER_AGENT" => user_agent }))
  end
end
