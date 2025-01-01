module Masks
  class Token < ApplicationRecord
    self.table_name = "masks_tokens"

    class << self
      def copy!(token)
        copy(token).tap { |t| t.save! }
      end

      def copy(token)
        new(
          actor: token.actor,
          device: token.device,
          client: token.client,
          entry: token.entry,
          redirect_uri: token.redirect_uri,
          scopes: token.scopes,
          nonce: token.nonce,
        )
      end
    end

    include Scoped
    include Cleanable

    scope :usable,
          -> { where("revoked_at IS NULL AND expires_at >= ?", Time.now.utc) }

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :device, class_name: "Masks::Device", optional: true
    belongs_to :actor, class_name: "Masks::Actor", optional: true
    belongs_to :entry, class_name: "Masks::Entry", optional: true

    after_initialize :generate_token
    before_validation :generate_defaults

    validates :type, :client, :secret, :expires_at, presence: true
    validates :secret, uniqueness: true
    validates :key, uniqueness: true

    validates :device, :entry, :actor, presence: true, if: :validate_entry?

    serialize :settings, coder: JSON

    def usable?
      !revoked_at && expires_at >= Time.now.utc
    end

    def valid_redirect_uri?(value)
      ActiveSupport::SecurityUtils.secure_compare(value, self.redirect_uri)
    end

    def obfuscated_secret
      obfuscate(:secret)
    end

    def public_id
      key
    end

    def public_type
      expiry_name.dasherize
    end

    def self.setting(name)
      define_method(name) do
        self.settings ||= {}
        self.settings[name.to_s]&.presence
      end

      define_method("#{name}=") do |value|
        self.settings ||= {}
        self.settings[name.to_s] = value
      end
    end

    private

    def validate_entry?
      true
    end

    def generate_token
      self.key ||= SecureRandom.base58(64)
      self.secret ||= SecureRandom.base58(64)
      self.settings ||= {}
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
