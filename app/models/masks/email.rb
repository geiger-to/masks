module Masks
  class Email < ApplicationRecord
    LOGIN_GROUP = "login"

    self.table_name = "masks_emails"

    scope :for_login, -> { where(group: LOGIN_GROUP) }

    scope :verified_for_login, -> { for_login.where.not(verified_at: nil) }
    scope :unverified_for_login, -> { for_login.where(verified_at: nil) }
    scope :verified, -> { where.not(verified_at: nil) }
    scope :unverified, -> { where(verified_at: nil) }

    validates :address,
              presence: true,
              uniqueness: {
                scope: :group,
              },
              email: true

    validate :within_limits

    belongs_to :actor

    has_many :login_links, class_name: "Masks::LoginLink"

    def deletable?
      persisted? && actor.emails.for_login.count >= 2
    end

    def permanently_delete
      destroy if deletable?
    end

    def expired_verification?(client)
      !verified? ||
        Time.now.utc > (verified_at + client.email_verification_duration)
    end

    def for_login
      self.group = LOGIN_GROUP
      self
    end

    def for_login?
      group == LOGIN_GROUP
    end

    def verify!
      touch(:verified_at)
    end

    def verified?
      verified_at&.present?
    end

    def unverified?
      !verified
    end

    def too_many?
      return false unless actor && new_record?

      actor.emails.for_login.count >=
        Masks.setting(:email, :max_for_login, default: 5)
    end

    private

    def within_limits
      errors.add(:base, "login-email-limit") if too_many?
    end
  end
end
