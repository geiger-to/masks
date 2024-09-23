# frozen_string_literal: true
module Masks
      class IdToken < ApplicationRecord
        self.table_name = "masks_id_tokens"

        belongs_to :tenant, class_name: 'Masks::Tenant'
        belongs_to :client, class_name: "Masks::Client"
        belongs_to :device, class_name: 'Masks::Device'
        belongs_to :actor,  class_name: "Masks::Actor"

        validates :nonce, presence: true

        def to_response_object(with = {})
          subject =
            if client.pairwise_subject?
              client.subject_for(actor)
            else
              actor.actor_id
            end

          claims = {
            sub: subject,
            iss: client.issuer,
            aud: client.audience,
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
          to_response_object(with).to_jwt(client.private_key) do |jwt|
            jwt.kid = client.kid
          end
        end
      end
end
