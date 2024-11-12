module Masks
  # Keeps track of historical auth attempts.
  class History < ApplicationModel
    ONBOARD_EVENT = "onboard"

    attribute :request
    attribute :device
    attribute :client
    attribute :auth_id
    attribute :required_scopes
    attribute :password
    attribute :event
    attribute :updates
    attribute :authenticator_prompt
    attribute :warnings
    attribute :login_link
    attribute :upload

    delegate :session, to: :request

    validates :actor, :client, :session, :device, presence: true

    def leak_actor?
      !authenticating?
    end

    def event?(name)
      (event || "").split("+").include?(name.to_s)
    end

    def path
      auth_session[:path] if auth_session
    end

    def authorize!
      return unless client

      params =
        client.authorize_params(
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

      auth_session[:path] = request.path
      auth_session[:params] = params

      self.actor = find_actor

      authenticators.each(&:prompt!)
    end

    def authenticate!(
      id:,
      identifier: nil,
      event: nil,
      password: nil,
      upload: nil,
      updates: {}
    )
      @identifier = identifier

      self.auth_id = id
      self.actor = find_actor
      self.event = event
      self.password = password
      self.updates = updates || {}
      self.upload = upload

      auth_session[:identifier] = identifier if identifier

      session[:identifiers] ||= {}
      session[:identifiers][identifier] = identifier

      authenticated = authenticated?
      authenticators.each { |auth| auth.event!(event) if event }

      authenticators.each(&:prompt!)

      return unless actor&.persisted?

      actor.touch(:last_login_at) if !authenticated && authenticated?

      oidc.authorize!(event)
    end

    def authenticated!(time)
      actor_session[:authenticated_at] = time
    end

    def denied!(error)
      @error = error
    end

    def oidc
      @oidc ||=
        Masks::OIDCRequest.new(self) do |oidc|
          if oidc.approved?
            auth_session[:authorized_at] = Time.now.utc.iso8601
            auth_session[:redirect_uri] = oidc.redirect_uri

            if client.internal?
              auth_session[:redirect_uri] = params[:redirect_uri]
            end
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

    def warnings
      @warnings ||= []
    end

    def warn!(*keys)
      warnings << keys.compact.join(":")
      @warnings.uniq!
    end

    def extras(**additions)
      @extras ||= {}
      @extras.deep_merge!(additions)
      @extras
    end

    def redirect_uri
      return @redirect_uri if @redirect_uri

      authorized? ? auth_session[:redirect_uri] : params[:redirect_uri]
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

      authenticators.all?(&:authenticated?)
    end

    def authenticating?
      return true unless actor&.persisted?

      expired_time?(actor_session[:authenticated_at])
    end

    attr_accessor :actor

    def find_actor
      return unless identifier&.present?

      actor =
        if identifier.include?("@") && Masks.installation.emails?
          Masks::Actor.from_login_email(identifier)
        elsif Masks.installation.nicknames?
          Masks::Actor.find_or_initialize_by(nickname: identifier)
        else
          Masks::Actor.new(identifier: identifier)
        end

      denied!("invalid_identifier") if actor.new_record? && !actor.valid?

      actor
    end

    def identifier=(identifier)
      @identifier = identifier
    end

    def identifier
      @identifier
    end

    def actor_session
      return {} unless actor&.persisted?

      session[:actors] ||= {}
      session[:actors][actor.key] ||= {}
    end

    def id_session
      return unless identifier

      session["id:#{identifier}"] ||= {}
    end

    def login_session
      return unless auth_session && actor&.persisted?

      auth_session["actor:#{actor.key}"] ||= {}
    end

    def auth_session
      session[:auth] ||= {}

      @auth_session ||=
        if auth_id
          time = session.dig(:auth, auth_id, :expires_at)

          if !time || expired_time?(time)
            session[:auth][auth_id] = {
              expires_at: client.auth_attempt_expires_at,
            }
          end

          session[:auth][auth_id]
        end
    end

    def client
      key = session.dig(:auth, auth_id, :params, :client_id) if auth_id

      if key
        @client ||= Masks::Client.find_by(key:)
      else
        super
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

    def params
      auth_session&.fetch(:params, nil) || {}
    end

    private

    def authenticators
      @authenticators ||= [
        Authenticators::Identifier.new(self),
        Authenticators::LoginLink.new(self),
        Authenticators::Credential.new(self),
        Authenticators::SecondFactor.new(self),
        Authenticators::Phone.new(self),
        Authenticators::Webauthn.new(self),
        Authenticators::Totp.new(self),
        Authenticators::BackupCode.new(self),
        Authenticators::VerifyEmail.new(self),
      ].each(&:prepare!).filter(&:enabled?).compact
    end
  end
end
