module Masks
  class Phone < ApplicationRecord
    self.table_name = "masks_phones"

    validates :number, phone: true, uniqueness: true

    belongs_to :actor

    def send_code
      send_via_twilio if twilio
    end

    def verify_code(code)
      return unless valid?

      verified = verify_via_twilio(code) if twilio

      if verified
        self.verified_at = Time.now.utc
        save
      end
    end

    def number=(value)
      number = Phonelib.parse(value)

      super number.e164 if number.valid?
    end

    private

    def twilio
      account_sid = Masks.setting(:twilio, :account_sid)
      auth_token = Masks.setting(:twilio, :auth_token)

      @twilio ||=
        Twilio::REST::Client.new(account_sid, auth_token) if account_sid &&
        auth_token
    end

    def send_via_twilio
      @verification ||=
        twilio
          .verify
          .v2
          .services(service_sid)
          .verifications
          .create(to: number, channel: "sms")

      @verification.status == "pending"
    end

    def verify_via_twilio(code)
      @check ||=
        twilio
          .verify
          .v2
          .services(service_sid)
          .verification_checks
          .create(to: number, code:)

      @check.status == "approved"
    end

    def service_sid
      Masks.setting(:twilio, :service_sid)
    end
  end
end
