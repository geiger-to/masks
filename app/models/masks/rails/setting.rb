module Masks
  module Rails
    class Setting < ApplicationRecord
      self.table_name = 'settings'

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

      validates :name, presence: true, uniqueness: true, inclusion: { in: NAMES }
      serialize :value, coder: JSON
    end
  end
end
