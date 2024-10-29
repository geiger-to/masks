module Masks
  class Email < ApplicationRecord
    LOGIN_VERIFIED_GROUP = "login-verified"
    LOGIN_UNVERIFIED_GROUP = "login-unverified"
    LOGIN_GROUPS = [LOGIN_VERIFIED_GROUP, LOGIN_UNVERIFIED_GROUP]

    self.table_name = "masks_emails"

    scope :for_login,
          -> do
            where(group: Masks::Email::LOGIN_GROUPS).order(
              Arel.sql(
                "CASE masks_emails.group WHEN '#{LOGIN_VERIFIED_GROUP}' THEN 1 WHEN '#{LOGIN_UNVERIFIED_GROUP}' THEN 2 END",
              ),
            )
          end

    validates :address,
              presence: true,
              uniqueness: {
                scope: :group,
              },
              email: true

    belongs_to :actor

    has_many :login_links, class_name: "Masks::LoginLink"

    def verify!
      update_attribute(:group, LOGIN_VERIFIED_GROUP)
    end

    def verified?
      group == LOGIN_VERIFIED_GROUP
    end

    def unverified?
      group == LOGIN_UNVERIFIED_GROUP
    end
  end
end
