module Masks
  class LoginLink < ApplicationRecord
    self.table_name = "masks_login_links"

    scope :active,
          -> { where("revoked_at IS NULL AND expires_at > ?", Time.current) }

    attribute :history

    has_secure_token :token

    belongs_to :client
    belongs_to :email
    belongs_to :actor

    after_initialize :set_defaults

    serialize :settings, coder: JSON

    validates :reset_url, :reject_url, :origin_url, :accept_url, presence: true

    def revoked?
      revoked_at&.present? || (expires_at && expires_at > Time.now.utc)
    end

    def email=(email)
      self.actor ||= email&.actor

      super email
    end

    def reject_url
      origin_url(login_link: token, reject: true)
    end

    def reset_url
      origin_url(login_link: token, reset: true)
    end

    def accept_url
      origin_url(login_link: token, accept: true)
    end

    def origin_url(**extras)
      Masks.url + settings["path"] + "?" +
        (extras.merge(**settings.fetch("params")).to_query)
    end

    def set_defaults
      self.expires_at ||= client&.login_link_expires_at
      self.settings ||= { path: history.path, params: history.params }
    end

    def copy_actor
      self.actor ||= email&.actor
    end
  end
end
