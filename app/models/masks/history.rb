module Masks
  class History < ApplicationModel
    attribute :request
    attribute :device
    attribute :client
    attribute :auth_id

    delegate :session, to: :request
    delegate :nickname, to: :actor, allow_nil: true

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
    end

    def resume!(id)
      self.auth_id = id

      return unless actor

      if session[:actor_id] != actor.key
        session[:actor_id] = actor.key
        session[:actor_ids] ||= []
        session[:actor_ids] << actor.key
        session[:actor_ids].uniq!

        log_event("identified")
      end
    end

    def error
      session.delete(:error)
    end

    def nickname
      actor&.nickname
    end

    def redirect_uri
      return @redirect_uri if @redirect_uri

      if authorized?
        return auth_session[:redirect_uri]
      else
        return oidc_params[:redirect_uri]
      end
    end

    def authenticate!(password)
      return unless client

      unless actor&.authenticate(password)
        log_event("invalid_password") if actor

        return deny! "invalid credentials"
      end

      actor_session[:password_entered_at] = Time.now.utc.iso8601
      actor.touch(:last_login_at)

      log_event("authenticated")
    end

    def authorize!(**opts)
      return unless oidc_params && authenticated? && !redirect_uri

      Masks::OIDCRequest.perform(self, **opts) do |oidc|
        if oidc.approved?
          auth_session[:authorized_at] = Time.now.utc.iso8601
          auth_session[:redirect_uri] = oidc.redirect_uri

          if client.internal?
            client_session[:code] = oidc.authorization.code
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

    def deny!(msg)
      session[:error] = msg
    end

    def authorization
      @authorization ||=
        Masks::Authorization.active.find_by(
          code: client_session[:code],
        ) if client_session&.fetch(:code, nil)
    end

    def authorized?
      return false unless authenticated? && auth_session

      !client.consent || valid_time?(auth_session[:authorized_at])
    end

    def authenticated?
      return false unless actor

      valid_time?(actor_session[:password_entered_at])
    end

    attr_writer :actor

    def actor
      @actor ||=
        (Masks::Actor.find_by(key: session[:actor_id]) if session[:actor_id])
    end

    def actor_session
      session[:actors] ||= {}
      session[:actors][actor.key] ||= {} if actor
    end

    def client
      if id = auth_session&.dig(:params, :client_id)
        @client ||= Masks::Client.find_by(key: id)
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
      session[:auth][auth_id] ||= {} if auth_id
    end

    def valid_time?(value)
      time = Time.parse(value)
      time < Time.now.utc
    rescue TypeError
      false
    end

    def log_event(key, **args)
      Masks::Event.create!(key:, device:, actor:, client:, **args)
    end

    def oidc_params
      auth_session&.fetch(:params, nil)
    end
  end
end
