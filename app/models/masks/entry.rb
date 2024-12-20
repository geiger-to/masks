# frozen_string_literal: true

module Masks
  class Entry < ApplicationRecord
    self.table_name = "masks_entries"

    belongs_to :actor, class_name: "Masks::Actor"
    belongs_to :client, class_name: "Masks::Client"
    belongs_to :device, class_name: "Masks::Device", optional: true

    after_initialize :generate_id, unless: :public_id

    private

    def generate_id
      self.public_id ||= SecureRandom.alphanumeric(255)
    end
  end
end
