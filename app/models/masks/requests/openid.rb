# frozen_string_literal: true
module Masks
  module Requests
    # Manages authorizations for OpenID/OAuth2 requests.
    class OpenID < ApplicationModel
      attr_accessor :client, :scopes, :response, :response_type

      attribute :tenant
      attribute :profile
      attribute :request
      attribute :client
      attribute :scopes
      attribute :actor
      attribute :device
      attribute :query

      attribute :authorization
      attribute :code
      attribute :access_token
      attribute :bearer_token
      attribute :id_token
      attribute :jwt

      attribute :redirect_uri

      delegate :env, to: :request

      attribute :response
      attribute :redirect_uri
      attribute :approved
      attribute :denied

      def approve!
        return if approved || denied

        self.approved = true
        self.redirect_uri = authorize
      end

      def deny!
        return if approved || denied

        self.denied = true
        self.redirect_uri = authorize
      end

      def authorize
        app = Rack::OAuth2::Server::Authorize.new do |req, res|
          req.bad_request!(:client_id, "not found") unless client && client.key == req.client_id

          unless req.redirect_uri
            req.invalid_request!('"redirect_uri" missing')
          end

          unless client.redirect_uris.any?
            client.redirect_uris = [req.redirect_uri.to_s]
            client.valid? || req.invalid_request!('"redirect_uri" invalid')
          end

          redirect_uris = client.redirect_uris.map do |uri|
            if uri.end_with?('*') && req.redirect_uri.to_s.start_with?(uri.slice(0..-2))
              req.redirect_uri.to_s
            else
              uri
            end
          end

          res.redirect_uri = req.verify_redirect_uri!(redirect_uris)

          self.scopes = req.scope & client.scopes

          if actor && (scopes - actor.scopes).any?
            req.bad_request! "invalid_scopes", "request scopes are unavailable"
          end

          if res.protocol_params_location == :fragment && req.nonce.blank?
            req.invalid_request! "nonce required"
          end

          if client.response_types.include?(
               Array(req.response_type).collect(&:to_s).join(" ")
             )
            if denied
              req.access_denied!
            elsif actor && approved
              client.save if client.redirect_uris_changed?

              approved! req, res
            end
          else
            req.unsupported_response_type!
          end
        end

        status, headers, body = app.call(query ? env.merge("QUERY_STRING" => query) : env)

        return unless status > 300 && status < 399 && headers['location']

        headers['location']
      end

      def approved!(req, res)
        response_types = Array(req.response_type)

        if response_types.include? :code
          self.authorization ||=
            actor.authorizations.create!(
              tenant:,
              client:,
              device: device.record,
              redirect_uri: res.redirect_uri,
              nonce: req.nonce,
              scopes:
            )

          self.code = res.code = authorization.code
        end

        if response_types.include? :token
          self.access_token ||=
            actor.access_tokens.create!(
              tenant:,
              client:,
              device: device.record,
              scopes:
            )

          self.bearer_token = res.access_token = access_token.to_bearer_token
        end

        if response_types.include? :id_token
          self.id_token ||=
            actor.id_tokens.create!(
              tenant:,
              expires_at: client.id_token_expires_at,
              device: device.record,
              client: @client,
              nonce: req.nonce
            )

          self.jwt ||= res.id_token =
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
