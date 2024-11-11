module Masks
  class WebauthnCredential < ApplicationRecord
    self.table_name = "masks_webauthn_credentials"

    validates :name, :external_id, :public_key, :sign_count, presence: true
    validates :external_id, uniqueness: { scope: :aaguid }
    validates :sign_count,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: 2**32 - 1,
              }

    belongs_to :actor
    belongs_to :device
  end
end
