module Masks
  class Phone < ApplicationRecord
    self.table_name = "masks_phones"

    validates :number, phone: true, uniqueness: true

    belongs_to :actor

    def send_code
      integration.notify
    end

    def verify_code(code)
      return unless valid?

      if integration.verify(code)
        self.verified_at = Time.now.utc
        save
      end
    end

    def number=(value)
      number = Phonelib.parse(value)

      super number.e164 if number.valid?
    end

    private

    def integration
      @integration ||=
        case Masks.setting(:integration, :phone)
        when "twilio"
          Masks::Integration::TwilioPhone.new(self)
        when "test"
          Masks::Integration::TestPhone.new(self)
        else
          Masks::Integration::NilPhone.new(self)
        end
    end
  end
end
