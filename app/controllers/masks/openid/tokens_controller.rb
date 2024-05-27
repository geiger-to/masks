# frozen_string_literal: true
module Masks
  module OpenID
    class TokensController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action { device.client }

      def create
        app =
          Rack::OAuth2::Server::Token.new do |req, res|
            @client ||= tenant.clients.find_by(key: req.client_id)

            req.invalid_client! if !client || client.secret != req.client_secret

            unless client.grant_types.include?(req.grant_type.to_s)
              req.unsupported_grant_type!
            end

            @token_request = req
            @grant_type = req.grant_type

            if @grant_type == :authorization_code
              @redirect_uri = req.redirect_uri
              @code = req.code
            end

            send(@grant_type)

            res.access_token = @access_token.to_bearer_token if @access_token
          end

        status, headers, body = app.call(request.env)
        headers.each { |k, v| response.set_header(k, v) }
        render status:, json: body.first
      end

      private

      attr_reader :client, :grant_type, :redirect_uri, :code

      def client_credentials
        @access_token =
          client.access_tokens.create!(tenant:, device: device.record)
      end

      def authorization_code
        authorization = client.authorizations.valid.where(code: @code).first

        unless authorization&.valid_redirect_uri?(@redirect_uri)
          @token_request.invalid_grant!
        end

        @access_token = authorization.access_token
      end
    end
  end
end
