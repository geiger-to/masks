# frozen_string_literal: true

module Masks
    class Scope < ApplicationRecord
      self.table_name = "masks_scopes"

      validates :name, presence: true, uniqueness: { scope: %i[actor_id] }

      belongs_to :actor,
                 class_name: "Masks::Actor"
    end
end
