module Masks
  class Installation < ApplicationRecord
    self.table_name = "masks_installation"

    serialize :settings, coder: JSON

    def name
      settings[:name] || "masks"
    end

    def settings
      super || {}
    end

    def seed!
      save!
    end
  end
end