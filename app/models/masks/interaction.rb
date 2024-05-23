# frozen_string_literal: true

module Masks
  class Interaction < ApplicationRecord
    self.table_name = "masks_interactions"

    belongs_to :tenant, class_name: 'Masks::Tenant'
    belongs_to :actor, class_name: 'Masks::Actor'
    belongs_to :device, class_name: 'Masks::Device'
    belongs_to :client, class_name: 'Masks::Client', optional: true

    validates :key, presence: true

    def name
      key
    end
  end
end
