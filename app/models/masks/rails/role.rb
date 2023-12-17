module Masks
  module Rails
    class Role < ApplicationRecord
      self.table_name = "roles"

      validates :type, uniqueness: true

      belongs_to :actor, class_name: Masks.configuration.models[:actor]
      belongs_to :record, polymorphic: true, autosave: true
    end
  end
end
