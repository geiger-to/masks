module Masks
  module Rails
    class ActorScope < ApplicationRecord
      self.table_name = "actor_scopes"

      belongs_to :actor, class_name: Masks.configuration.models[:actor]
      belongs_to :scope, class_name: Masks.configuration.models[:scope]
    end
  end
end
