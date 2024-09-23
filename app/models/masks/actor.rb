# frozen_string_literal: true

module Masks
  class Actor < ApplicationRecord
    include Scoped

    self.table_name = "masks_actors"

    has_many :saved_scopes, class_name: "Masks::Scope", autosave: true
    has_many :authorizations, class_name: "Masks::Authorization", autosave: true
    has_many :access_tokens, class_name: "Masks::AccessToken", autosave: true
    has_many :id_tokens, class_name: "Masks::IdToken", autosave: true
    has_many :clients, class_name: "Masks::Client", through: :access_tokens
    has_many :devices,
             class_name: "Masks::Device",
             through: :access_tokens,
             autosave: true

    has_secure_password

    attribute :signup
    attribute :session
    attribute :totp_code

    after_initialize :generate_key, unless: :key
    before_validation :reset_version, unless: :version

    validates :totp_secret, presence: true, if: :totp_code
    validates :version, presence: true
    validate :validates_totp, if: :totp_code

    before_save :regenerate_backup_codes

    serialize :backup_codes, coder: JSON

    def version_digest
      return if new_record? || !valid?

      Digest::MD5.hexdigest([version, key].join("-"))
    end

    def to_param
      key
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

    def logout_everywhere!
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

      ROTP::TOTP.new(totp_secret, issuer: "TODO")
    end

    def random_totp
      ROTP::TOTP.new(random_totp_secret, issuer: "TODO")
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

    def should_save_backup_codes?
      factor2? && saved_backup_codes_at.blank?
    end

    def saved_backup_codes?
      factor2? && saved_backup_codes_at.present?
    end

    private

    def generate_key
      self.key ||= SecureRandom.uuid
    end

    def validates_totp
      errors.add(:totp_code, :invalid) unless totp.verify(totp_code)
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
