module Masks
  module OpenID
    class Token
      attr_accessor :app

      delegate :call, to: :app

      def initialize
        @app = Rack::OAuth2::Server::Token.new do |req, res|
          client = Masks.configuration.model(:openid_client).find_by(key: req.client_id) || req.invalid_client!
          client.secret == req.client_secret || req.invalid_client!

          case req.grant_type
          when :client_credentials
            res.access_token = client.access_tokens.create!.to_bearer_token
          when :authorization_code
            authorization = client.authorizations.valid.where(code: req.code).first
            req.invalid_grant! unless authorization&.valid_redirect_uri?(req.redirect_uri)
            access_token = authorization.access_token
            res.access_token = access_token.to_bearer_token

            if access_token.scoped?('openid')
              res.id_token = access_token.actor.openid_id_tokens.create!(
                openid_client: access_token.openid_client,
                nonce: authorization.nonce,
              ).to_jwt
            end
          else
            req.unsupported_grant_type!
          end
        end
      end
    end
  end
end
