module Masks
  module Rails
    class Role < ApplicationRecord
      include Masks::Role

      self.table_name = "roles"

      belongs_to :actor, polymorphic: true, autosave: true
      belongs_to :record, polymorphic: true, autosave: true

      validates :type,
                presence: true,
                uniqueness: {
                  scope: %i[actor_id actor_type record_id record_type]
                }
    end
  end
end
