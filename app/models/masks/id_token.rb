# frozen_string_literal: true

module Masks
  class IdToken < ApplicationRecord
    self.table_name = "masks_id_tokens"

    include Cleanable

    cleanup :expires_at do
      0.seconds
    end

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :device, class_name: "Masks::Device"
    belongs_to :actor, class_name: "Masks::Actor"

    validates :nonce, presence: true
    validates :expires_at, presence: true

    after_initialize :generate_expires_at

    def to_response_object(with = {})
      subject =
        (client.pairwise_subject? ? client.subject_for(actor) : actor.actor_id)

      claims = {
        sub: subject,
        iss: client.issuer,
        aud: client.audience,
        exp: expires_at.to_i,
        iat: created_at.to_i,
        nonce:,
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

    private

    def generate_expires_at
      self.expires_at ||= client.expires_at(:id_token)
    end
  end
end
