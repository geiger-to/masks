# frozen_string_literal: true

module Masks
  module Rails
    class ActorRole < ApplicationRecord
      self.table_name = "actor_roles"

      belongs_to :actor, class_name: Masks.configuration.models[:actor]
      belongs_to :role, class_name: Masks.configuration.models[:role]
    end
  end
end
