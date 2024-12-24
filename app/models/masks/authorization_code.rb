# frozen_string_literal: true

module Masks
  class AuthorizationCode < ApplicationRecord
    self.table_name = "masks_authorization_codes"

    include Scoped
    include Cleanable

    cleanup :expires_at do
      0.seconds
    end

    after_initialize :generate_code

    scope :active, -> { where("expires_at >= ?", Time.now.utc) }

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :device, class_name: "Masks::Device"
    belongs_to :actor, class_name: "Masks::Actor"

    has_many :access_tokens

    before_validation :generate_expiry

    validates :actor, presence: true
    validates :client, presence: true
    validates :code, presence: true, uniqueness: true
    validates :expires_at, presence: true

    def obfuscated_code
      obfuscate(:code)
    end

    def valid_redirect_uri?(uri)
      uri == redirect_uri
    end

    def access_token
      @access_token ||=
        update_attribute!(:expires_at, Time.now) && generate_access_token!
    end

    def generate_access_token!
      return if expires_at > Time.current

      actor.access_tokens.create!(device:, client:, scopes:)
    end

    private

    def generate_code
      self.code ||= SecureRandom.base58(64)
    end

    def generate_expiry
      self.expires_at ||= client.expires_at(:code)
    end
  end
end
