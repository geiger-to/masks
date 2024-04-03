# frozen_string_literal: true
module Masks
  module Rails
    module OpenID
      class IdToken < ApplicationRecord
        self.table_name = "openid_id_tokens"

        belongs_to :actor, class_name: Masks.configuration.models[:actor]
        belongs_to :openid_client,
                   class_name: Masks.configuration.models[:openid_client]

        def to_response_object(with = {})
          subject =
            if openid_client.pairwise_subject?
              openid_client.subject_for(actor)
            else
              actor.actor_id
            end

          claims = {
            sub: subject,
            iss: openid_client.issuer,
            aud: openid_client.audience,
            exp: expires_at.to_i,
            iat: created_at.to_i,
            nonce:
          }

          id_token = OpenIDConnect::ResponseObject::IdToken.new(claims)
          id_token.code = with[:code] if with[:code]
          id_token.access_token = with[:access_token] if with[:access_token]
          id_token
        end

        def to_jwt(with = {})
          to_response_object(with).to_jwt(openid_client.private_key) do |jwt|
            jwt.kid = openid_client.private_key_id
          end
        end
      end
    end
  end
end
