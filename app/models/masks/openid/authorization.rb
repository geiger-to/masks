# frozen_string_literal: true
module Masks
  module OpenID
    # Manages authorizations for OpenID/OAuth2 requests.
    class Authorization
      attr_accessor :client, :scopes, :response, :response_type

      class << self
        def perform(env, **opts)
          authorization = new(env, **opts)
          authorization.perform
          authorization
        end
      end

      def initialize(env, **opts)
        @env = env
        @app =
          Rack::OAuth2::Server::Authorize.new do |req, res|
            @client =
              session.config.model(:openid_client).find_by(key: req.client_id)

            req.bad_request!(:client_id, "not found") unless @client
            res.redirect_uri = req.verify_redirect_uri!(@client.redirect_uris)

            @scopes = req.scope & @client.scopes

            if res.protocol_params_location == :fragment && req.nonce.blank?
              req.invalid_request! "nonce required"
            end

            # @request_object = if (@_request_ = req.request).present?
            #   OpenIDConnect::RequestObject.decode req.request, nil # @client.secret
            # elsif (@request_uri = req.request_uri).present?
            #   OpenIDConnect::RequestObject.fetch req.request_uri, nil # @client.secret
            # end

            if @client.response_types.include?(
                 Array(req.response_type).collect(&:to_s).join(" ")
               )
              if actor
                if opts[:approved] || client.auto_consent?
                  approved! req, res
                elsif opts.key?(:approved)
                  req.access_denied!
                end
              end
            else
              req.unsupported_response_type!
            end
          end
      end

      def session
        @session ||= @env[Masks::Middleware::SESSION_KEY]
      end

      def actor
        @actor ||= (session.actor if session.passed?)
      end

      def perform
        @response = @app.call(@env)
      end

      def approved!(req, res)
        response_types = Array(req.response_type)

        if response_types.include? :code
          authorization =
            actor.openid_authorizations.create!(
              openid_client: client,
              redirect_uri: res.redirect_uri,
              nonce: req.nonce,
              scopes: @scopes
            )

          res.code = authorization.code
        end

        if response_types.include? :token
          access_token =
            actor.openid_access_tokens.create!(
              openid_client: client,
              scopes: @scopes
            )

          res.access_token = access_token.to_bearer_token
        end

        if response_types.include? :id_token
          id_token =
            actor.openid_id_tokens.create!(
              openid_client: @client,
              nonce: req.nonce
            )

          res.id_token =
            id_token.to_jwt(
              code: (res.respond_to?(:code) ? res.code : nil),
              access_token:
                (res.respond_to?(:access_token) ? res.access_token : nil)
            )
        end

        res.approve!
      end
    end
  end
end
