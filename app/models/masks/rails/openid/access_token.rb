# frozen_string_literal: true
module Masks
  module Rails
    module OpenID
      class AccessToken < ApplicationRecord
        self.table_name = "openid_access_tokens"

        belongs_to :actor,
                   class_name: Masks.configuration.models[:actor],
                   optional: true
        belongs_to :openid_client,
                   class_name: Masks.configuration.models[:openid_client]

        serialize :scopes, coder: JSON

        after_initialize :generate_token

        validates :openid_client, presence: true
        validates :token, presence: true, uniqueness: true
        validates :expires_at, presence: true

        def scoped?(*scopes)
          scopes.all? { |scope| self.scopes.include?(scope) }
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
          self.expires_at ||= 1.day.from_now
          self.scopes ||= []
        end
      end
    end
  end
end
