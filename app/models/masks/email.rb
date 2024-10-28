module Masks
  class Email < ApplicationRecord
    LOGIN_GROUP = "login"

    self.table_name = "masks_emails"

    validates :address,
              presence: true,
              uniqueness: {
                scope: :group,
              },
              email: true

    belongs_to :actor
  end
end
