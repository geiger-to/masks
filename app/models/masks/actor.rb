# frozen_string_literal: true

module Masks
    class Actor < ApplicationRecord
      include Scoped

      self.table_name = "masks_actors"

      belongs_to :tenant, class_name: 'Masks::Tenant'

      has_many :identifiers,
               class_name: 'Masks::Identifier',
               autosave: true, validate: false
      has_many :saved_scopes,
               class_name: 'Masks::Scope',
               autosave: true
      has_many :authorizations,
               class_name: 'Masks::Authorization',
               autosave: true
      has_many :access_tokens,
               class_name: 'Masks::AccessToken',
               autosave: true
      has_many :id_tokens,
               class_name: 'Masks::IdToken',
               autosave: true
      has_many :clients,
               class_name: 'Masks::Client',
               through: :access_tokens
      has_many :devices,
               class_name: 'Masks::Device',
               through: :access_tokens,
               autosave: true

      has_secure_password

      attribute :signup
      attribute :session
      attribute :totp_code

      after_initialize :generate_uuid, unless: :uuid
      before_validation :reset_version, unless: :version

      validates :totp_secret, presence: true, if: :totp_code
      validates :version, presence: true
      validates :identifiers, length: { minimum: 1 }
      validate :validates_totp, if: :totp_code
      validate :validates_identifiers

      before_save :regenerate_backup_codes

      serialize :backup_codes, coder: JSON

      # A unique identifier for the actor.
      #
      # This value is used for internal references to actors, e.g. when they are
      # stored in the rails session.
      #
      # @return [String]
      def actor_id
        uuid
      end

      # A session identifier for the actor.
      #
      # This value is used for internal references to actors, e.g. when they are
      # stored in the rails session.
      #
      # @return [String]
      def session_key
        return if new_record? || !valid?

        Digest::MD5.hexdigest(
          [tenant.version, version, uuid].join("-")
        )
      end

      def to_param
        public_id.value
      end

      def accepted_ids
        identifiers.where(type: tenant.identifiers.values.map(&:to_s))
      end

      def public_id
        accepted_ids.first
      end

      def verified_ids
        identifiers.where('verified_at')
      end

      def identifier
        identifiers.first
      end

      def nickname
        identifiers.where(type: Masks.configuration.model(:nickname_id).to_s).first&.value
      end

      def phone_number
        identifiers.where(type: Masks.configuration.model(:phone_id).to_s).first
      end

      def email
        identifiers.where(type: Masks.configuration.model(:email_id).to_s).first
      end

      def factor2?
        backup_codes.present?
      end

      def remove_factor2!
        self.added_totp_secret_at = nil
        self.saved_backup_codes_at = nil
        self.totp_secret = nil
        self.backup_codes = nil
        save!
      end

      def logout!
        reset_version
        save!
      end

      def totp_uri
        (totp || random_totp).provisioning_uri(uuid)
      end

      def totp_svg(**opts)
        qrcode = RQRCode::QRCode.new(totp_uri)
        qrcode.as_svg(**opts)
      end

      def totp
        return unless totp_secret

        ROTP::TOTP.new(totp_secret, issuer: tenant.issuer)
      end

      def random_totp
        ROTP::TOTP.new(random_totp_secret, issuer: tenant.issuer)
      end

      def random_totp_secret
        @random_totp_secret ||= ROTP::Base32.random
      end

      def assign_scopes(*list)
        list.map { |scope| saved_scopes.find_or_initialize_by(name: scope) }
      end

      def assign_scopes!(*list)
        list.map { |scope| saved_scopes.find_or_create_by(name: scope) }
      end

      def remove_scopes!(*list)
        saved_scopes.where(name: list).destroy_all
      end

      def scopes
        @scopes ||= saved_scopes.order(created_at: :desc).pluck(:name)
      end

      def mask!
        save # sub-classes are encouraged to override
      end

      def should_save_backup_codes?
        factor2? && saved_backup_codes_at.blank?
      end

      def saved_backup_codes?
        factor2? && saved_backup_codes_at.present?
      end

      private

      def generate_uuid
        self.uuid ||= SecureRandom.uuid
      end

      def validates_totp
        errors.add(:totp_code, :invalid) unless totp.verify(totp_code)
      end

      def validates_identifiers
        identifiers.each do |identifier|
          next if !identifier.changed? || identifier.valid?

          errors.add(:base, identifier.errors.full_messages.first)
        end
      end

      def reset_version
        self.version = SecureRandom.hex
      end

      def regenerate_backup_codes
        if factor2?
          self.backup_codes ||=
            (1..12).to_h { |_i| [SecureRandom.base58(10), true] }
        else
          self.backup_codes = nil
          self.saved_backup_codes_at = nil
        end
      end
    end
end
