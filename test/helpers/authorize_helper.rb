module AuthorizeHelper
  extend ActiveSupport::Concern

  PREFIX = %i[data authorize]

  attr_reader :auth_id

  def user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"
  end

  def client
    @client ||= Masks::Client.find_by(key: client_id)
  end

  def client_id
    Masks::Client::MANAGE_KEY
  end

  def authorize_result(r = nil)
    (r || response).parsed_body.dig(*PREFIX)
  end

  def refute_error_code(r = nil)
    refute authorize_result(r).dig(:errorCode)
  end

  def assert_actor(id, r = nil)
    assert_equal id, authorize_result(r).dig(:actor, :identifier)
  end

  def assert_client(r = nil)
    assert_equal client_id, authorize_result(r).dig(:client, :id)
  end

  def assert_error_code(code, r = nil)
    assert_equal code, authorize_result(r).dig(:errorCode)
  end

  def refute_authenticated(r = nil)
    refute authorize_result(r).dig(:authenticated)
  end

  def refute_authorized(r = nil)
    refute authorize_result(r).dig(:successful)
  end

  def assert_authenticated(r = nil)
    assert authorize_result(r).dig(:authenticated)
  end

  def assert_authorized(r = nil, redirect_uri: nil)
    assert_authenticated(r)
    data = authorize_result(r)
    assert data.dig(:redirectUri)
    assert_equal redirect_uri, data.dig(:redirectUri) if redirect_uri
    assert data.dig(:successful)
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

  def attempt(**vars)
    query = <<-GQL
        mutation ($input: AuthorizeInput!) {
          authorize(input: $input) {
            errorMessage
            errorCode
            identifier
            identiconId
            authenticated
            successful
            settled
            redirectUri
            prompt
            actor {
              identifier
            }
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
               id: @auth_id,
               **vars,
             },
           },
         }

    response
  end

  def authorize(**opts)
    opts = (self.class.authorize_options || {}).merge(opts)
    assert client

    params =
      opts.slice(:redirect_uri, :scope, :response_type, :client_id, :nonce)
    params[:client_id] = client_id unless params[:path] || params[:client_id]

    get "#{opts.fetch(:path, "/authorize")}?#{params.to_query}"

    @auth_id = response.headers["X-Masks-Auth-Id"]

    response
  end

  def get(*args, **opts, &block)
    super(
      *args,
      **opts.merge(headers: { "HTTP_USER_AGENT" => user_agent }),
      &block
    )
  end

  def post(*args, **opts, &block)
    super(
      *args,
      **opts.merge(headers: { "HTTP_USER_AGENT" => user_agent }),
      &block
    )
  end

  def assert_artifacts(devices: 0, tokens: 0, jwts: 0, codes: 0)
    assert_equal codes, Masks::AuthorizationCode.count
    assert_equal devices, Masks::Device.count
    assert_equal tokens, Masks::AccessToken.count
    assert_equal jwts, Masks::IdToken.count
  end

  included { cattr_accessor :authorize_options }

  class_methods do
    def test_authorization(**opts)
      self.authorize_options = opts

      test "manage client is returned" do
        authorize
        attempt
        assert_client
        assert_artifacts(devices: 1)
      end

      test "invalid redirect_uris return an error" do
        authorize(redirect_uri: "https://example.com/invalid")
        assert_equal 400, status
        refute auth_id
        assert_artifacts(devices: 1)
      end

      test "empty redirect_uris accept the first supplied" do
        client.update_attribute(:redirect_uris, nil)
        authorize(redirect_uri: "https://example.com/invalid")
        refute_error_code attempt
        assert auth_id
      end

      test "empty redirect_uris save the first supplied, after authorization" do
        first = "https://example.com/first"
        client.update_attribute(:redirect_uris, nil)
        authorize(redirect_uri: first)
        assert_authorized attempt(
                            event: "approve+onboard",
                            identifier: "manager",
                            password: "password",
                          )
        assert_equal(first, client.reload.redirect_uris)
      end

      test "attempts expire after 1 hour" do
        freeze_time

        authorize

        assert_authorized attempt(
                            identifier: "manager",
                            password: "password",
                            event: "approve+onboard",
                          )

        travel_to client.auth_attempt_expires_at do
          assert_authorized attempt
        end

        travel_to client.auth_attempt_expires_at + 1.second do
          refute_authorized attempt
        end
      end

      test "passwords expire after 1 day" do
        freeze_time

        authorize

        assert_authorized attempt(
                            identifier: "manager",
                            password: "password",
                            event: "approve+onboard",
                          )

        travel_to client.password_expires_at do
          authorize
          assert_authenticated attempt
        end

        travel_to client.password_expires_at + 1.second do
          authorize
          refute_authenticated attempt
        end
      end

      test "invalid_credentials for invalid passwords" do
        authorize

        assert_equal "invalid_credentials",
                     attempt(
                       identifier: "manager",
                       password: "invalid",
                       event: "approve+onboard",
                     ).parsed_body.dig(*PREFIX, :errorCode)

        refute_authorized
        assert_artifacts(devices: 1)
      end

      test "invalid_credentials for unknown actors" do
        authorize
        attempt(
          identifier: "invalid",
          password: "invalid",
          event: "approve+onboard",
        ).parsed_body.dig(*PREFIX, :errorCode)

        refute_authorized
        assert_error_code "invalid_credentials"
        assert_artifacts(devices: 1)
      end
    end
  end
end
