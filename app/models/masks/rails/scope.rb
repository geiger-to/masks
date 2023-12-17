module Masks
  module Rails
    class Scope < ApplicationRecord
      self.table_name = "scopes"

      validates :name, uniqueness: true

      has_many :actor_scopes, class_name: "Masks::Rails::ActorScope"
      has_many :actors, through: :actor_scopes, class_name: "Masks::Rails::Scope"
    end
  end
end
