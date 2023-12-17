# frozen_string_literal: true

module Masks
  # Integrate masks with Rails, via middleware.
  #
  # This middleware creates a new session for every request using
  # +Masks.request+. If the session is +passed?+ the middleware
  # chain is allowed to continue.
  #
  # The middleware uses the +fail+ value on the session's mask to
  # determine what to do otherwise. If +false+ the chain is allowed
  # to continue regardless of pass/fail status. It will also accept
  # a URI or path for redirects, an HTTP status code, or a controller
  # action in the form of +ControllerClass#action_name+.
  #
  # The session is stored in the rack environment under the name
  # +Mask::Middleware::SESSION_KEY+, which is how it is made available to
  # controllers in +Masks::Controller#masked_session+.
  #
  # @see Masks.request Masks.request
  # @see Masks::Session Masks::Session
  # @see Masks::Controller Masks::Controller
  class Middleware
    SESSION_KEY = "masks.session"

    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      session = Masks.request(request)

      ::Rails.logger.info(
        [
          "Mask #{session.passed? ? "allowed" : "blocked"}",
          "by type=#{session.mask.type}",
          session.mask.name ? "name=#{session.mask.name}" : ""
        ].join(" ")
      )

      env[SESSION_KEY] = session
      app = @app
      app = (session.passed? ? app : error_app(session, app))

      app.call(env)
    end

    private

    def error_app(session, app)
      value = session.mask.fail
      case value
      when false
        app
      when /.+\#.+/
        controller, action = value.split("#")
        controller.constantize.action(action)
      when %r{/.*}, %r{https?://.+}
        Masks::ErrorController.action(:redirect)
      when /\d+/
        Masks::ErrorController.action("render_#{value}")
      when /\w+/
        Masks::ErrorController.action(value)
      else
        Masks::ErrorController.action(:render_unauthorized)
      end
    end
  end
end
