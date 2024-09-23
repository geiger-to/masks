# frozen_string_literal: true

module Masks
  class Authorization < ApplicationRecord
    self.table_name = "masks_authorizations"

    scope :valid, -> { where("expires_at >= ?", Time.now.utc) }

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :device, class_name: "Masks::Device"
    belongs_to :actor, class_name: "Masks::Actor"

    serialize :scopes, coder: JSON

    before_validation :generate_code

    validates :actor, presence: true
    validates :client, presence: true
    validates :code, presence: true, uniqueness: true
    validates :expires_at, presence: true

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
      self.code ||= SecureRandom.uuid
      self.expires_at ||= client.code_expires_at
    end
  end
end
