module Masks
  module Rails
    class Key < ApplicationRecord
      include Masks::Scoped

      self.table_name = "keys"

      class << self
        def sha(secret)
          Digest::SHA512.hexdigest(secret)
        end
      end

      scope :latest, -> { order(created_at: :desc) }

      attribute :session
      attribute :secret

      serialize :scopes, coder: JSON

      belongs_to :actor, class_name: Masks.configuration.models[:actor]

      after_initialize :generate_hash

      validates :name, presence: true, length: { maximum: 32 }
      validates :sha, presence: true, uniqueness: true

      def nickname
        [name.parameterize, sha.slice(0...32)].join("-")
      end

      alias_method :slug, :nickname

      def scopes
        value = self[:scopes]

        return [] unless value

        value & (actor&.scopes || [])
      end

      def roles_for(record, **opts)
        []
      end

      private

      def generate_secret
        self.secret ||= SecureRandom.uuid
      end

      def generate_hash
        self.secret ||= SecureRandom.uuid

        self.sha = self.class.sha(secret) if self.secret
      end
    end
  end
end
