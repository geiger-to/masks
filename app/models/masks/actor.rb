# frozen_string_literal: true

module Masks
  class Actor < ApplicationRecord
    self.table_name = "masks_actors"

    EMAIL_ID = "email"
    NICKNAME_ID = "nickname"

    class << self
      def from_login_email(email)
        email = Masks::Email.for_login.where(address: email).first
        email&.actor ||
          Masks::Actor
            .new(identifier: email)
            .tap { |a| a.emails.build(address: email) }
      end
    end

    has_one_attached :avatar do |attachable|
      attachable.variant :preview, resize_to_limit: [350, 350]
    end

    has_many :authorization_codes,
             class_name: "Masks::AuthorizationCode",
             autosave: true
    has_many :emails, class_name: "Masks::Email", autosave: true
    has_many :access_tokens, class_name: "Masks::AccessToken", autosave: true
    has_many :id_tokens, class_name: "Masks::IdToken", autosave: true
    has_many :events, class_name: "Masks::Event"
    has_many :clients, class_name: "Masks::Client", through: :events
    has_many :devices,
             class_name: "Masks::Device",
             through: :events,
             autosave: true

    has_secure_password validations: false

    attribute :signup
    attribute :session
    attribute :totp_code

    after_initialize :generate_key, unless: :key
    before_validation :reset_version, unless: :version

    validates :identifier_type, presence: true
    validates :nickname,
              uniqueness: true,
              format: {
                with: /\A[a-z][a-z0-9\-]+\z/,
              }
    validates :totp_secret, presence: true, if: :totp_code
    validates :version, presence: true
    validate :validates_password, if: :password
    validate :validates_totp, if: :totp_code

    before_save :regenerate_backup_codes

    serialize :backup_codes, coder: JSON

    include Scoped

    def tz
      super || Masks.installation.settings["timezone"]
    end

    def new_login_link!
      return unless persisted? && login_email

      link = Masks::LoginLink.create!(email: login_email)
      link
    end

    def onboarded!
      touch(:onboarded_at)
    end

    def onboarded?
      onboarded_at
    end

    def public_id
      key
    end

    def identifier_type
      if Masks.installation.nicknames? && nickname
        NICKNAME_ID
      elsif Masks.installation.emails? && login_email&.valid?
        EMAIL_ID
      end
    end

    attr_writer :identifier

    def identifier
      @identifier ||=
        begin
          case identifier_type
          when EMAIL_ID
            login_email.address
          when NICKNAME_ID
            nickname
          end
        end
    end

    def avatar_created_at
      avatar.created_at if avatar&.attached?
    end

    def avatar_url
      if avatar&.attached?
        Rails.application.routes.url_helpers.rails_storage_proxy_url(
          avatar.variant(:preview),
        )
      end
    end

    def identicon_id
      @identicon_id ||=
        (Digest::MD5.hexdigest("identicon-#{identifier}") if identifier)
    end

    def login_email
      emails.for_login.first
    end

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

    def validates_password
      opts = Masks.installation.passwords

      return unless password && opts

      if opts[:min] && password.length < opts[:min]
        errors.add(:password, :too_short, count: opts[:min])
      elsif opts[:max] && password.length > opts[:max]
        errors.add(key, :too_long, count: opts[:max])
      end
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
