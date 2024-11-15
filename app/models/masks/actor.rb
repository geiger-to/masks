# frozen_string_literal: true

module Masks
  class Actor < ApplicationRecord
    self.table_name = "masks_actors"

    EMAIL_ID = "email"
    NICKNAME_ID = "nickname"

    class << self
      def from_login_email(address)
        email = Masks::Email.for_login.where(address:).first
        email&.actor ||
          Masks::Actor
            .new(identifier: address)
            .tap { |a| a.emails.build(address:).for_login }
      end
    end

    has_many :authorization_codes,
             class_name: "Masks::AuthorizationCode",
             autosave: true
    has_many :emails, class_name: "Masks::Email", autosave: true
    has_many :phones, class_name: "Masks::Phone", autosave: true
    has_many :access_tokens, class_name: "Masks::AccessToken", autosave: true
    has_many :id_tokens, class_name: "Masks::IdToken", autosave: true
    has_many :events, class_name: "Masks::Event"
    has_many :clients, class_name: "Masks::Client", through: :events
    has_many :devices,
             class_name: "Masks::Device",
             through: :events,
             autosave: true

    has_many :login_links, class_name: "Masks::LoginLink", autosave: true
    has_many :webauthn_credentials,
             class_name: "Masks::WebauthnCredential",
             autosave: true
    has_many :otp_secrets, class_name: "Masks::OtpSecret", autosave: true

    has_one_attached :avatar do |attachable|
      attachable.variant :preview, resize_to_limit: [350, 350]
    end

    has_secure_password validations: false

    attribute :signup
    attribute :session

    after_initialize :generate_defaults
    before_validation :reset_version, unless: :version

    validates :identifier_type, presence: true
    validates :nickname,
              uniqueness: true,
              presence: true,
              format: {
                with: /\A[a-z][a-z0-9\-]+\z/,
              },
              if: :nickname_required?
    validates :version, presence: true
    validate :validates_password, if: :password

    serialize :backup_codes, coder: JSON

    include Scoped

    def tz
      super || Masks.installation.settings["timezone"]
    end

    def session_key
      version
    end

    def onboarded!
      touch(:onboarded_at)
    end

    def onboarded?
      onboarded_at
    end

    def unverified_email?
      emails.verified_for_login.none?
    end

    def change_password(v)
      return unless password_changeable?

      self.password = v
      self.password_changed_at = Time.now.utc
    end

    def password_changeable?
      cooldown = Masks.setting(:password, :change_cooldown)

      return true unless password_changed_at && cooldown

      password_changed_at + ChronicDuration.parse(cooldown) < Time.now.utc
    rescue => e
      true
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
      persisted? ? emails.for_login.first : emails.select(&:for_login?).first
    end

    def version_digest
      return if new_record? || !valid?

      Digest::MD5.hexdigest([version, key].join("-"))
    end

    def to_param
      key
    end

    def second_factor?
      enabled_second_factor_at.present?
    end

    def enable_second_factor!
      return if second_factors.none? || backup_codes&.blank?

      touch(:enabled_second_factor_at)
    end

    def second_factors
      @second_factors ||= [
        *(phones.all.to_a),
        *(webauthn_credentials.all.to_a),
        *(otp_secrets.all.to_a),
      ].compact
    end

    def logout_everywhere!
      reset_version
      save!
    end

    def verify_backup_code(code)
      return false unless code && backup_codes&.any?

      hash = Digest::SHA256.hexdigest(code)

      if backup_codes.include?(hash)
        backup_codes.delete(hash)
        save
      end
    end

    def save_backup_codes(codes)
      self.saved_backup_codes_at = Time.now.utc
      self.backup_codes = codes.map { |code| Digest::SHA256.hexdigest(code) }

      save
    end

    private

    def nickname_required?
      nickname || (Masks.installation.nicknames? && !Masks.installation.emails?)
    end

    def generate_defaults
      self.key ||= SecureRandom.uuid
      self.webauthn_id ||= WebAuthn.generate_user_id
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
  end
end
