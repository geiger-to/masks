module Masks
  class Installation < ApplicationRecord
    self.table_name = "masks_installations"

    serialize :settings, coder: JSON
    encrypts :settings

    scope :active, -> { where(expired_at: nil) }

    def name
      settings[:name] || "masks"
    end

    def modify(updates)
      self.class.new(
        settings:
          updates.slice(:url, :name, :email, :smtp, :sendmail, :storage),
      )
    end

    def settings
      super || {}
    end

    def seed!
      save!
    end
  end
end
