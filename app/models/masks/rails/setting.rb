module Masks
  module Rails
    class Setting < ApplicationRecord
      self.table_name = 'settings'

      NAMES = %w[
        name
        title
        logo
        favicon
        signups
        version
      ]

      validates :name, presence: true, uniqueness: true
      serialize :value, coder: JSON
    end
  end
end
