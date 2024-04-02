# frozen_string_literal: true

module Masks
  module Rails
    class Actor < ApplicationRecord
      include Masks::Actor

      self.table_name = "actors"

      scope :expired,
            lambda {
              where(
                "last_login_at < ?",
                Masks.configuration.lifetimes[:expired_actor]&.ago ||
                  6.months.ago
              )
            }

      has_many :saved_scopes,
               class_name: Masks.configuration.models[:scope],
               autosave: true
      has_many :saved_roles,
               class_name: Masks.configuration.models[:role],
               autosave: true
      has_many :recoveries,
               class_name: Masks.configuration.models[:recovery],
               autosave: true
      has_many :emails, class_name: Masks.configuration.models[:email]
      has_many :devices,
               class_name: Masks.configuration.models[:device],
               autosave: true
      has_many :keys,
               class_name: Masks.configuration.models[:key],
               autosave: true
      has_many :openid_authorizations,
               class_name: Masks.configuration.models[:openid_authorization],
               autosave: true
      has_many :openid_access_tokens,
               class_name: Masks.configuration.models[:openid_access_token],
               autosave: true
      has_many :openid_id_tokens,
               class_name: Masks.configuration.models[:openid_id_token],
               autosave: true

      has_secure_password

      attribute :signup
      attribute :session
      attribute :totp_code

      before_validation :reset_version, unless: :version

      validates :nickname, uniqueness: { case_sensitive: false }
      validates :totp_secret, presence: true, if: :totp_code
      validates :version, presence: true
      validate :validates_totp, if: :totp_code
      validate :validates_password, if: :password
      validate :validates_signup

      before_save :regenerate_backup_codes

      serialize :backup_codes, coder: JSON

      def email_addresses
        emails.pluck(:email)
      end

      def factor2?
        phone_number || totp_secret
      end

      def remove_factor2!
        self.added_totp_secret_at = nil
        saved_backup_codes_at
        self.totp_secret = nil
        self.backup_codes = nil
        save!
      end

      def totp_uri
        (totp || random_totp).provisioning_uri(nickname)
      end

      def totp_svg(**opts)
        qrcode = RQRCode::QRCode.new(totp_uri)
        qrcode.as_svg(**opts)
      end

      def totp
        return unless totp_secret

        ROTP::TOTP.new(totp_secret, issuer: Masks.configuration.issuer)
      end

      def random_totp
        ROTP::TOTP.new(random_totp_secret, issuer: Masks.configuration.issuer)
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

      def assign_role(record, **opts)
        saved_roles
          .find_by!(record:)
          .tap { |role| role.assign_attributes(**opts) }
      rescue ActiveRecord::RecordNotFound
        saved_roles.build(record:, **opts)
      end

      def assign_role!(record, **opts)
        assign_role(record, **opts).save!
      end

      def remove_role!(record)
        saved_roles.where(record:).destroy_all
      end

      def scopes
        @scopes ||= saved_scopes.order(created_at: :desc).pluck(:name)
      end

      def roles(record, **opts)
        case record
        when Class, String
          saved_roles.where(record_type: record.to_s, **opts).includes(:record)
        else
          saved_roles.where(record:, **opts)
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

      def changed_during_mask?
        changed? && changes.keys != ["session"]
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

      def validates_signup
        return unless !persisted? && !Masks.configuration.signups? && signup

        errors.add(:signup, :disabled)
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
end
