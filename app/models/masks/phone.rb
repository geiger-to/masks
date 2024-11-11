module Masks
  class Phone < ApplicationRecord
    self.table_name = "masks_phones"

    validates :number, phone: true, uniqueness: true

    belongs_to :actor

    def number=(value)
      number = Phonelib.parse(value)

      super number.e164 if number.valid?
    end
  end
end
