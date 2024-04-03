# frozen_string_literal: true

module Masks
  module Credentials
    # Checks :key given a valid Authorization header.
    class AccessToken < Masks::Credential
      checks :access_token

      def lookup
        access_token =
          session.config.model(:openid_access_token).valid.find_by(token:)

        return unless access_token&.actor

        session.extras(access_token:)
        session.scoped = access_token

        access_token.actor
      end

      def maskup
        access_token = session.extra(:access_token)

        if access_token&.actor && access_token&.actor == session&.actor &&
             session.scoped == access_token
          approve!
        else
          deny!
        end
      end

      private

      def token
        return if [header_token, param_token].uniq.compact.length != 1

        header_token || param_token
      end

      def header_token
        unless auth_header.provided? && !auth_header.parts.first.nil? &&
                 auth_header.scheme.to_s == "bearer"
          return
        end

        auth_header.params
      end

      def param_token
        params[:access_token]
      end

      def auth_header
        return unless session.try(:request)

        @auth_header = Rack::Auth::AbstractRequest.new(session.request.env)
      end
    end
  end
end
