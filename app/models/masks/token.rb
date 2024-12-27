module Masks
  class Token < ApplicationRecord
    self.table_name = "masks_tokens"

    include Scoped
    include Cleanable

    scope :valid,
          -> { where("revoked_at IS NULL AND expires_at >= ?", Time.now.utc) }

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :device, class_name: "Masks::Device", optional: true
    belongs_to :actor, class_name: "Masks::Actor", optional: true
    belongs_to :entry, class_name: "Masks::Entry", optional: true

    after_initialize :generate_token
    before_validation :generate_defaults

    validates :type, :client, :secret, :expires_at, presence: true
    validates :secret, uniqueness: true

    def obfuscated_secret
      obfuscate(:secret)
    end

    private

    def generate_token
      self.secret ||= SecureRandom.base58(64)
    end

    def generate_defaults
      self.expires_at ||= client.expires_at(expiry_name)
      self.scopes ||= []
    end

    def expiry_name
      self.class.name.split("::").last.underscore
    end
  end
end
