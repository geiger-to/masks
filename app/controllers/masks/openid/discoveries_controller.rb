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

        render json: [jwks]
      end

      def new
        render json:
                 OpenIDConnect::Discovery::Provider::Config::Response.new(
                   issuer: client.issuer,
                   authorization_endpoint:
                     openid_authorization_url(host: site_url),
                   token_endpoint: openid_token_url(host: site_url),
                   userinfo_endpoint: openid_userinfo_url(host: site_url),
                   jwks_uri: openid_jwks_url(host: site_url),
                   registration_endpoint: site_url, # TODO
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
                   claims_supported: %w[sub iss name email address phone_number]
                 )
      end

      private

      def find_client
        head :not_found unless client
      end

      def client
        @client ||=
          Masks.configuration.model(:openid_client).find_by(key: params[:id])
      end

      def site_url
        Masks.configuration.site_url
      end
    end
  end
end
