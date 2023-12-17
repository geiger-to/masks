module Masks
  module Rails
    class Scope < ApplicationRecord
      self.table_name = "scopes"

      validates :name, presence: true, uniqueness: { scope: :actor_id }

      belongs_to :actor,
                 polymorphic: true,
                 class_name: Masks.configuration.models[:actor]
    end
  end
end
