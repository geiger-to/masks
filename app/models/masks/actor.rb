# frozen_string_literal: true

module Masks
  class Actor < ApplicationRecord
    include Cleanable

    self.table_name = "masks_actors"

    EMAIL_ID = "email"
    NICKNAME_ID = "nickname"

    class << self
      def from_login_email(address)
        email = Masks::Email.for_login.where(address:).first
        email&.actor || with_login_email(address)
      end

      def with_login_email(address)
        Masks::Actor
          .new(identifier: address)
          .tap { |a| a.emails.build(address:).for_login }
      end
    end

    cleanup :last_login_at do
      Masks.installation.duration(:actors, :inactive)
    end

    has_many :emails, class_name: "Masks::Email", autosave: true
    has_many :phones, class_name: "Masks::Phone", autosave: true
    has_many :tokens, class_name: "Masks::Token", autosave: true
    has_many :entries, class_name: "Masks::Entry"
    has_many :devices,
             -> { distinct },
             class_name: "Masks::Device",
             through: :entries
    has_many :clients,
             -> { distinct },
             class_name: "Masks::Client",
             through: :entries

    has_many :login_links, class_name: "Masks::LoginLink", autosave: true
    has_many :hardware_keys, class_name: "Masks::HardwareKey", autosave: true
    has_many :otp_secrets, class_name: "Masks::OtpSecret", autosave: true

    has_one_attached :avatar do |attachable|
      attachable.variant :preview, resize_to_limit: [350, 350]
    end

    has_secure_password validations: false

    attribute :signup
    attribute :session

    after_initialize :generate_defaults
    before_validation :generate_key, unless: :key, on: :create

    validates :identifier_type, presence: true
    validates :key, presence: true, uniqueness: true
    validates :nickname,
              uniqueness: true,
              presence: true,
              format: {
                with: /\A[a-zA-Z][a-zA-Z0-9\-]+\z/,
              },
              if: :nickname_required?
    validate :validates_password, if: :password
    validate :validates_backup_codes, if: :backup_codes
    validates_associated :emails

    serialize :backup_codes, coder: JSON

    include Scoped

    def tz
      super || Masks.installation.settings["timezone"]
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

    def reset_password
      self.password_digest = nil
      self.password_changed_at = nil
    end

    def change_password(v)
      self.password = v
    end

    def password_changeable?
      return true unless password_changed_at && password_settings[:cooldown]

      password_changeable_at < Time.now.utc
    rescue => e
      true
    end

    def password_changeable_at
      return unless password_settings[:cooldown] && password_changed_at

      Masks.time.expires_at(
        password_settings[:cooldown],
        after: password_changed_at,
      )
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
        case identifier_type
        when EMAIL_ID
          login_email.address
        when NICKNAME_ID
          nickname
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
      @identicon_id ||= (Digest::MD5.hexdigest("identicon-#{key}") if key)
    end

    def login_email
      persisted? ? login_emails.first : emails.select(&:for_login?).first
    end

    def login_emails
      emails.for_login
    end

    def to_param
      key
    end

    def second_factor?
      enabled_second_factor_at.present?
    end

    def review_second_factor?
      second_factor? && !backup_codes&.any?
    end

    def enable_second_factor!
      return if second_factors.none? || backup_codes&.blank?

      touch(:enabled_second_factor_at)
    end

    def second_factors
      @second_factors ||= [
        *(phones.all.to_a),
        *(hardware_keys.all.to_a),
        *(otp_secrets.all.to_a),
      ].compact
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
      @new_backup_codes = true

      self.backup_codes = codes

      return unless valid?

      self.saved_backup_codes_at = Time.now.utc
      self.backup_codes = codes.map { |code| Digest::SHA256.hexdigest(code) }

      save
    ensure
      @new_backup_codes = false
    end

    def reset_backup_codes
      self.backup_codes = nil
      self.saved_backup_codes_at = nil
    end

    private

    def nickname_required?
      nickname || (Masks.installation.nicknames? && !Masks.installation.emails?)
    end

    def generate_defaults
      self.webauthn_id ||= WebAuthn.generate_user_id
    end

    def generate_key
      self.key ||=
        if identifier&.present?
          key = identifier.parameterize

          loop do
            break if self.class.where(key:).none?

            key =
              "#{identifier.parameterize}-#{SecureRandom.hex([*1..4].sample)}"
          end

          key
        else
          SecureRandom.hex
        end
    end

    def validates_length(value, key:, min_chars:, max_chars:)
      return unless value

      if min_chars && value.length < min_chars
        errors.add(key, :too_short, count: min_chars)
      elsif max_chars && value.length > max_chars
        errors.add(key, :too_long, count: max_chars)
      end
    end

    def validates_password
      return unless password && password_settings

      if password_changeable?
        self.password_changed_at = Time.current if persisted?
      else
        time =
          ApplicationController.helpers.distance_of_time_in_words(
            Time.current,
            password_changeable_at,
          )

        errors.add(:password, :unchangeable, time:)
      end

      validates_length(
        password,
        key: :password,
        **password_settings.slice(:min_chars, :max_chars),
      )
    end

    def validates_backup_codes
      opts = backup_code_settings

      return unless backup_codes && opts && @new_backup_codes

      if opts[:total]
        unless backup_codes.length == opts[:total]
          errors.add(:backup_codes, :length, total: opts[:total])
        end
      end

      validates_length(
        backup_codes,
        key: :backup_codes,
        **opts.slice(:min_chars, :max_chars),
      )
    end

    def password_settings
      @password_settings ||= Masks.installation.passwords
    end

    def backup_code_settings
      @backup_code_settings ||= Masks.installation.backup_codes
    end
  end
end
