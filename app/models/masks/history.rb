module Masks
  class History < ApplicationModel
    attribute :session_id
    attribute :session
    attribute :device

    def error
      session.delete(:error)
    end

    def nickname
      actor.nickname if actor
    end

    def redirect_uri
      return nil unless authenticated?
    end

    def identify(actor:, **args)
      if session[:actor_id] != actor.key
        session[:actor_id] = actor.key

        log_event('actor.identified', actor:, **args)
      end
    end

    def authenticate(actor:, **args)
      if actor == self.actor
        actor_session[:password_entered_at] = Time.now.utc.iso8601

        log_event('actor.authenticated', actor:, **args)

        actor.touch(:last_login_at)
      end
    end

    def denied(msg, actor: nil, **args)
      actor_session[:password_entered_at] = nil if actor
      session[:error] = msg
    end

    def authorized?(client)
      return false unless authenticated?

      authorized_at = actor_session["#{client.key}_authorized_at"]

      !client.consent || valid_time?(authorized_at)
    end

    def authenticated?
      return false unless actor

      valid_time?(actor_session[:password_entered_at])
    end

    def logged_in?
      actor&.present?
    end

    def actor
      @actor ||= if session[:actor_id]
        Masks::Actor.find_by(key: session[:actor_id])
      end
    end

    def events
      @events ||= Masks::Event.where(session_id:)
    end

    def actor_session
      session[:actors] ||= {}
      session[:actors][actor.key] ||= {} if actor
    end

    def valid_time?(value)
      time = Time.parse(value)
      time < Time.now.utc
    rescue TypeError
      false
    end

    def log_event(name, **args)
      Masks::Event.create!(key: 'actor.identified', session_id:, device:, actor:, **args)
    end
  end
end
