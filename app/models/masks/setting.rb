module Masks
    class Setting < ApplicationRecord
      self.table_name = 'masks_settings'

      NAMES = %w[
        url
        name
        logo
        theme
        background
        favicon
        signups.enabled
        dark_mode.logo
        dark_mode.theme
        dark_mode.background
        nickname.prefix
        nickname.allowed
        nickname.signups
        nickname.minimum
        nickname.maximum
        email.allowed
        email.signups
        phone.allowed
        phone.signups
        password.minimum
        password.maximum
      ]

      belongs_to :tenant, class_name: "Masks::Tenant"

      validates :name, presence: true, uniqueness: true, inclusion: { in: NAMES }
      serialize :value, coder: JSON
    end
end
