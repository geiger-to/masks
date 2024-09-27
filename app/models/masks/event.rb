module Masks
  class Event < ApplicationRecord
    self.table_name = "masks_events"

    validates :key, :session_id, presence: true

    belongs_to :actor
    belongs_to :device
    belongs_to :client

    serialize :data, coder: JSON
  end
end
