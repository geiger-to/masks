module AuthHelper
  extend ActiveSupport::Concern

  PREFIX = %i[data authenticate]

  attr_reader :auth_id

  def user_agent
    @user_agent ||= [
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
      "AppleWebKit/605.1.15 (KHTML, like Gecko)",
      "Version/17.4 Safari/605.1.15",
    ].join(" ")
  end

  def client
    @client ||= Masks::Client.find_by(key: client_id)
  end

  def client_id
    @client&.key || Masks::Client::MANAGE_KEY
  end

  def auth_result(r = nil)
    json = (r || response).parsed_body
    json[:requestId] ? json : json.dig(*PREFIX)
  end

  def refute_error(r = nil)
    assert_not auth_result(r).dig(:error)
  end

  def assert_actor(id, r = nil)
    assert_equal id, auth_result(r).dig(:actor, :identifier)
  end

  def assert_client(r = nil)
    assert_equal client_id, auth_result(r).dig(:client, :id)
  end

  def assert_error(code, r = nil)
    assert_equal code, auth_result(r).dig(:error)
  end

  def refute_settled(r = nil)
    assert_not auth_result(r).dig(:settled)
  end

  def assert_settled(r = nil)
    assert auth_result(r).dig(:settled)
  end

  def assert_login(r = nil, redirect_uri: nil)
    assert_settled(r)
    data = auth_result(r)
    assert data.dig(:redirectUri)
    assert_equal redirect_uri, data.dig(:redirectUri) if redirect_uri
    assert data.dig(:client)
    assert_not data.dig(:error)
    assert_prompt "success", r
  end

  def refute_prompt(prompt, r = nil)
    assert auth_result(r).dig(:prompt)
    assert_not_equal prompt, auth_result(r).dig(:prompt)
  end

  def assert_prompt(prompt, r = nil)
    assert_equal prompt, auth_result(r).dig(:prompt)
  end

  def assert_warning(code, r = nil)
    assert_includes auth_result(r).dig(:warnings), code
  end

  def refute_warnings(r = nil)
    assert_empty auth_result(r).dig(:warnings)
  end

  def assert_logged_in(method, path)
    send(method, path)
    assert_not_equal 302, status
  end

  def refute_logged_in(method, path)
    send(method, path)
    assert_equal 302, status
  end

  def log_in(identifier, password = "password", authorize: false, **args)
    authorize(**args)
    attempt_identifier(identifier)
    attempt_password(password)
    attempt_authorize if authorize
  end

  def setup_totp(*args)
    travel_to Time.parse("2024-11-17T19:57:11+0000") do
      log_in *args

      attempt event: "totp:verify",
              updates: {
                secret: "JBSWY3DPEHPK3PXP",
                code: "247086",
              }
      attempt event: "backup-codes:replace",
              updates: {
                codes: Array.new(10) { SecureRandom.uuid },
              }
      attempt event: "second-factor:enable"
    end

    integration_session.reset!
  end

  def attempt_identifier(identifier)
    attempt(event: "identifier:add", updates: { identifier: })
  end

  def attempt_password(password)
    attempt(event: "password:check", updates: { password: })
  end

  def attempt_authorize(r = nil)
    attempt(event: "authorize") if auth_result(r).dig(:prompt) == "authorize"
  end

  def authorize(**opts)
    assert client
    opts = self.class.auth_opts.merge(opts)

    params =
      opts.slice(:redirect_uri, :scope, :response_type, :client_id, :nonce)
    params[:client_id] = client_id unless params[:path] || params[:client_id]

    get "#{opts.fetch(:path, "/authorize.json")}?#{params.to_query}"

    @auth_id = response.headers["X-Masks-Auth-Id"]

    response
  end

  def attempt(**vars)
    assert client
    query = Masks.authenticate_gql
    params = vars.delete(:params) || {}

    post "/graphql",
         as: :json,
         params:
           params.merge(query:, variables: { input: { id: @auth_id, **vars } })

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

  def assert_empty_session
    assert_equal({ "written" => true }, request.session.to_h)
  end

  included { cattr_accessor :auth_options }

  class_methods do
    def auth_opts(**opts)
      self.auth_options ||= {}
      self.auth_options[self.name] ||= {}
      self.auth_options[self.name].merge!(**opts)
      self.auth_options[self.name]
    end
  end
end
