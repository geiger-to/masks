# frozen_string_literal: true
module Masks
  module OpenID
    class DiscoveriesController < ApplicationController
      before_action :find_client

      def jwks
        jwks =
          JSON::JWK::Set.new(
            JSON::JWK.new(client.public_key, use: :sig, kid: client.kid)
          )

        render json: jwks
      end

      def new
        render json:
                 OpenIDConnect::Discovery::Provider::Config::Response.new(
                   issuer: client.issuer,
                   authorization_endpoint: session_url,
                   token_endpoint: openid_token_url,
                   userinfo_endpoint: openid_userinfo_url,
                   jwks_uri: openid_jwks_url,
                   #  registration_endpoint: site_url, # TODO
                   scopes_supported: client.scopes,
                   response_types_supported: client.response_types,
                   grant_types_supported: client.grant_types,
                   claims_parameter_supported: false,
                   request_parameter_supported: false,
                   request_uri_parameter_supported: false,
                   subject_types_supported: [
                     client.pairwise_subject? ? "pairwise" : "public"
                   ],
                   id_token_signing_alg_values_supported: [:RS256],
                   token_endpoint_auth_methods_supported: %w[
                     client_secret_basic
                     client_secret_post
                   ],
                   claims_supported: %w[sub iss email phone_number]
                 )
      end

      private

      def find_client
        render_not_found if !client || client.internal?
      end

      def client
        @client ||= tenant.clients.find_by(key: params[:id])
      end
    end
  end
end
