# frozen_string_literal: true

module Masks
  class AccessToken < ApplicationRecord
    include Masks::Scoped

    self.table_name = "masks_access_tokens"

    has_secure_token :token

    scope :valid,
          -> { where("revoked_at IS NULL AND expires_at >= ?", Time.now.utc) }

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :authorization_code,
               class_name: "Masks::AuthorizationCode",
               optional: true
    belongs_to :device, class_name: "Masks::Device", optional: true
    belongs_to :actor, class_name: "Masks::Actor", optional: true

    serialize :scopes, coder: JSON

    before_validation :generate_defaults

    validates :client, presence: true
    validates :token, presence: true, uniqueness: true
    validates :expires_at, presence: true

    def obfuscated_token
      obfuscate(:token)
    end

    def scopes
      value = self[:scopes]

      return [] unless value

      value & ((actor&.scopes || []) + client.scopes)
    end

    def to_bearer_token
      Rack::OAuth2::AccessToken::Bearer.new(
        access_token: token,
        expires_in: (expires_at - Time.now.utc).to_i,
      )
    end

    private

    def generate_defaults
      self.expires_at ||= client.access_token_expires_at
      self.scopes ||= []
    end
  end
end
