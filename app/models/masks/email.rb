module Masks
  class Email < ApplicationRecord
    VERIFIED_GROUP = "verified"

    self.table_name = "masks_emails"

    scope :verified, -> { where(group: VERIFIED_GROUP) }

    validates :email, presence: true, uniqueness: { scope: :group }
    validates :email, uniqueness: true

    belongs_to :actor

    def verify
      self.group = VERIFIED_GROUP
    end
  end
end
