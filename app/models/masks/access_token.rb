# frozen_string_literal: true

module Masks
  class AccessToken < ApplicationRecord
    include Masks::Scoped

    self.table_name = "masks_access_tokens"

    scope :valid,
          -> { where("revoked_at IS NULL AND expires_at >= ?", Time.now.utc) }

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :authorization_code,
               class_name: "Masks::AuthorizationCode",
               optional: true
    belongs_to :device, class_name: "Masks::Device", optional: true
    belongs_to :actor, class_name: "Masks::Actor", optional: true

    after_initialize :generate_token
    before_validation :generate_defaults

    validates :client, presence: true
    validates :token, presence: true, uniqueness: true
    validates :expires_at, presence: true

    def obfuscated_token
      obfuscate(:token)
    end

    def to_bearer_token
      Rack::OAuth2::AccessToken::Bearer.new(
        access_token: token,
        expires_in: (expires_at - Time.now.utc).to_i,
      )
    end

    private

    def generate_token
      self.token ||= SecureRandom.base58(64)
    end

    def generate_defaults
      self.expires_at ||= client.expires_at(:access_token)
      self.scopes ||= []
    end
  end
end
