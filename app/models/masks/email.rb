module Masks
  class Email < ApplicationRecord
    LOGIN_GROUP = "login"

    self.table_name = "masks_emails"

    validates :email, presence: true, uniqueness: { scope: :group }
    validates :email, uniqueness: true

    belongs_to :actor
  end
end
