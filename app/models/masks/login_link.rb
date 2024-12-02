module Masks
  class LoginLink < ApplicationRecord
    self.table_name = "masks_login_links"

    scope :active,
          -> { where("revoked_at IS NULL AND expires_at > ?", Time.now.utc) }

    scope :for_verification, -> { where(log_in: false) }

    scope :for_login, -> { where(log_in: true) }

    attribute :auth

    belongs_to :client
    belongs_to :email
    belongs_to :actor
    belongs_to :device

    after_initialize :set_defaults

    serialize :settings, coder: JSON

    validates :code,
              presence: true,
              uniqueness: {
                scope: %i[email_id device_id client_id],
              }
    validates :expires_at, :origin_url, :accept_url, presence: true

    def chars
      code.length
    end

    def save_and_deliver
      return unless save

      mailer = LoginLinkMailer.with(login_link: self)

      log_in? ? mailer.authenticate.deliver_later : mailer.verify.deliver_later
    end

    def authenticated!
      return if authenticated?

      touch(:authenticated_at)

      verified!
    end

    def verified!
      email.verify!

      touch(:revoked_at)

      true
    end

    def authenticated?
      authenticated_at.present?
    end

    def reset_password(password)
      return unless !reset_password_at

      actor.password = password
      saved = actor.save

      touch(:reset_password_at) if saved

      saved
    end

    def active?
      !revoked?
    end

    def revoked?
      revoked_at&.present? || (expires_at && expires_at < Time.now.utc)
    end

    def email=(email)
      self.actor ||= email&.actor

      super email
    end

    def accept_url
      origin_url(login_code: code)
    end

    def origin_url(**extras)
      Masks.url + settings["path"] + "?" +
        (extras.merge(**settings.fetch("params")).to_query)
    end

    def set_defaults
      return unless auth

      self.code ||= SecureRandom.base36(7).upcase
      self.settings ||= { path: auth.path, params: auth.params }
      self.device ||= auth.device
      self.client ||= auth.client
      self.expires_at ||= client.expires_at(:login_link)
    end
  end
end
