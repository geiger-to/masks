module AuthorizationHelper
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

  def assert_prompt(prompt, r = nil)
    assert_equal prompt, authorize_result(r).dig(:prompt)
  end

  def assert_warning(code, r = nil)
    assert_includes authorize_result(r).dig(:warnings), code
  end

  def assert_logged_in(method, path)
    send(method, path)
    refute_equal 302, status
  end

  def refute_logged_in(method, path)
    send(method, path)
    assert_equal 302, status
  end

  def log_in(identifier, password = "password")
    authorize
    attempt_identifier(identifier)
    attempt_password(password)
  end

  def attempt_identifier(identifier)
    attempt(event: "identifier:add", updates: { identifier: })
  end

  def attempt_password(password)
    attempt(event: "password:check", updates: { password: })
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
            warnings
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

    params = vars.delete(:params) || {}

    post "/graphql",
         as: :json,
         params:
           params.merge(query:, variables: { input: { id: @auth_id, **vars } })

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
    end
  end
end
