module Masks
  module Rails
    class Actor < ApplicationRecord
      include Masks::Actor

      self.table_name = "actors"

      has_many :actor_scopes, class_name: Masks.configuration.models[:actor_scope]
      has_many :saved_scopes,
               through: :actor_scopes,
               class_name: Masks.configuration.models[:scope],
               source: :scope
      has_many :saved_roles, class_name: Masks.configuration.models[:role]

      has_many :recoveries, class_name: Masks.configuration.models[:recovery], autosave: true
      has_many :emails, class_name: Masks.configuration.models[:email]

      has_secure_password

      attribute :session
      attribute :totp_code

      validates :nickname, uniqueness: { case_sensitive: false }
      validates :totp_secret, presence: true, if: :totp_code
      validate :validates_totp, if: :totp_code
      validate :validates_password, if: :password

      before_save :regenerate_backup_codes

      serialize :backup_codes, coder: JSON

      def email_addresses
        emails.pluck(:email)
      end

      def factor2?
        phone_number || totp_secret
      end

      def totp_uri
        (totp || random_totp).provisioning_uri(nickname)
      end

      def totp_svg(**opts)
        qrcode = RQRCode::QRCode.new(totp_uri)
        qrcode.as_svg(**opts)
      end

      def totp
        ROTP::TOTP.new(totp_secret, issuer: Masks.configuration.issuer) if totp_secret
      end

      def random_totp
        ROTP::TOTP.new(random_totp_secret, issuer: Masks.configuration.issuer)
      end

      def random_totp_secret
        @random_totp ||= ROTP::Base32.random
      end

      def scopes
        @scopes ||= saved_scopes.pluck(:name)
      end

      def has_scope?(name)
        scopes.include?(name.to_s)
      end

      def has_role?(*args, **opts)
        roles_for(*args, **opts).any?
      end

      def roles_for(record, **opts)
        case record
        when Class, String
          saved_roles.where(record_type: record.to_s, **opts)
        else
          saved_roles.where(record: record, **opts)
        end
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

      def validates_totp
        errors.add(:totp_code, :invalid) unless totp.verify(totp_code)
      end

      def validates_password
        opts = Masks.configuration.dat.password&.length&.to_h

        return unless password && opts

        if opts[:min] && password.length < opts[:min]
          errors.add(:password, :too_short, count: opts[:min])
        elsif opts[:max] && password.length > opts[:max]
          errors.add(key, :too_long, count: opts[:max])
        end
      end

      def regenerate_backup_codes
        if !factor2?
          self.backup_codes = nil
          self.saved_backup_codes_at = nil
        else
          self.backup_codes ||= (1..12).map { |i| [SecureRandom.base58(10), true] }.to_h
        end
      end
    end
  end
end
