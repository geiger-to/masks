module Masks
  # Keeps track of historical auth attempts.
  #
  # Data is stored in the session and a few other data models.
  # Top-level session keys include:
  #
  #  - session[:auth] - a hash of auth attempts, keyed by id
  #  - session[:actors] - a list of all identified actors
  #  - session[:actor_id] - the last identified actor
  #
  # Various bang-methods can be used to track key events as
  # the agent moves through authentication. As they are called
  # various artificats are left in the session and database
  # to record state.
  #
  #  - start!        - creates a new auth request
  #  - resume!       - continues an auth request (e.g. from another place)
  #  - authenticate! - authenticates the current actor given a password
  #  - authorize!    - approve/deny the actor + client + scope combination
  #
  # Additional methods are available to interrogate state.
  class History < ApplicationModel
    attribute :request
    attribute :device
    attribute :client
    attribute :auth_id
    attribute :required_scopes

    delegate :session, to: :request

    validates :actor, :client, :session, :device, presence: true

    def start!
      return unless client

      params =
        client.oidc_params(
          request
            .params
            .slice(
              *%w[
                client_id
                response_type
                grant_type
                redirect_uri
                scope
                state
                nonce
              ],
            )
            .symbolize_keys,
        )

      query = params.sort_by { |k, _| k.to_s }.to_h.to_query

      self.auth_id = Digest::SHA256.hexdigest(query)

      auth_session[:params] = params

      oidc.validate!
    end

    def resume!(id, identifier = nil)
      self.auth_id = id
      self.actor = find_actor(identifier)

      return unless actor&.persisted?

      actor_session[:identified_at] = Time.now.utc.iso8601
      log_event("identified")
    end

    def authenticate!(password)
      return unless client && password&.present?

      unless actor&.authenticate(password)
        log_event("invalid_password") if actor&.persisted?

        return deny! "invalid_credentials"
      end

      actor_session[:password_expires_at] = client.password_expires_at
      actor.touch(:last_login_at)

      log_event("authenticated")

      session[:actor_id] = actor.key if session[:actor_id] != actor.key
    end

    def authorize!(event)
      oidc.authorize!(event)
      actor.onboarded! if authorized? && event&.include?("onboard")
    end

    def deny!(error)
      @error = error
    end

    def oidc
      @oidc ||=
        Masks::OIDCRequest.new(self) do |oidc|
          if oidc.approved?
            auth_session[:authorized_at] = Time.now.utc.iso8601
            auth_session[:redirect_uri] = oidc.redirect_uri

            if client.internal?
              auth_session[:redirect_uri] = oidc_params[:redirect_uri]
            end

            log_event("authorized")
          end

          if oidc.denied?
            auth_session[:authorized_at] = nil
            @redirect_uri = oidc.redirect_uri
          end
        end
    end

    def error
      @error ||= oidc.error
    end

    def redirect_uri
      return @redirect_uri if @redirect_uri

      authorized? ? auth_session[:redirect_uri] : oidc_params[:redirect_uri]
    end

    def required_scopes
      return unless @oidc

      @oidc.scopes - actor.scopes_a
    end

    def oidc_error?
      oidc.error&.present?
    end

    def successful?
      authorized? && redirect_uri && !error
    end

    def authorized?
      return false unless authenticated? && auth_session

      auth_session[:authorized_at]
    end

    def authenticated?
      return false unless actor&.persisted?

      !expired_time?(actor_session[:password_expires_at])
    end

    attr_accessor :actor

    def actor
      @actor ||=
        (Masks::Actor.find_by(key: session[:actor_id]) if session[:actor_id])
    end

    def find_actor(identifier)
      return unless identifier&.present?

      @identifier = identifier

      actor =
        if identifier.include?("@") && Masks.installation.emails?
          Masks::Actor.from_login_email(identifier)
        elsif Masks.installation.nicknames?
          Masks::Actor.find_or_initialize_by(nickname: identifier)
        else
          Masks::Actor.new(identifier: identifier)
        end

      deny!("invalid_identifier") if actor.new_record? && !actor.valid?

      actor
    end

    def identifier
      @identifier || actor&.identifier
    end

    def actor_session
      session[:actors] ||= {}
      session[:actors][actor.key] ||= {} if actor&.persisted?
    end

    def client
      key = session.dig(:auth, auth_id, :params, :client_id) if auth_id

      if key
        @client ||= Masks::Client.find_by(key:)
      else
        super
      end
    end

    def client_session
      session[:clients] ||= {}
      session[:clients][client.key] ||= {} if client
    end

    def auth_session
      session[:auth] ||= {}

      @auth_session ||=
        if auth_id
          time = session.dig(:auth, auth_id, :expires_at)

          if !time || expired_time?(time)
            session[:auth][auth_id] = { expires_at: client.history_expires_at }
          end

          session[:auth][auth_id]
        end
    end

    def expired_time?(value)
      time =
        case value
        when String
          Time.parse(value)
        else
          value
        end

      time < Time.now.utc
    rescue TypeError, NoMethodError
      true
    end

    def log_event(key, **args)
      Masks::Event.create!(key:, device:, actor:, client:, **args)
    end

    def oidc_params
      auth_session&.fetch(:params, nil) || {}
    end
  end
end
