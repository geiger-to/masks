# frozen_string_literal: true

module Masks
  class ProviderClient < ApplicationRecord
    self.table_name = "masks_provider_clients"

    belongs_to :client, class_name: "Masks::Client"
    belongs_to :provider, class_name: "Masks::Provider"

    validates :client_id, uniqueness: { scope: :provider_id }
  end
end
