# frozen_string_literal: true
module Masks
  module Rails
    module OpenID
      class AccessToken < ApplicationRecord
        include Masks::Scoped

        self.table_name = "openid_access_tokens"

        scope :valid, -> { where("expires_at >= ?", Time.now.utc) }

        belongs_to :actor,
                   class_name: Masks.configuration.models[:actor],
                   optional: true
        belongs_to :openid_client,
                   class_name: Masks.configuration.models[:openid_client]

        serialize :scopes, coder: JSON

        before_validation :generate_token

        validates :openid_client, presence: true
        validates :token, presence: true, uniqueness: true
        validates :expires_at, presence: true

        def scopes
          value = self[:scopes]

          return [] unless value

          value & ((actor&.scopes || []) + openid_client.scopes)
        end

        def roles(*args, **opts)
          (actor || openid_client).roles(*args, **opts)
        end

        def to_bearer_token
          Rack::OAuth2::AccessToken::Bearer.new(
            access_token: token,
            expires_in: (expires_at - Time.now.utc).to_i
          )
        end

        private

        def generate_token
          self.token ||= SecureRandom.uuid
          self.expires_at ||= openid_client.token_expires_at
          self.scopes ||= []
        end
      end
    end
  end
end
