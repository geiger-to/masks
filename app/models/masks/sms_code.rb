module Masks
  class SmsCode
    attr_reader :verification, :check

    def initialize(phone)
      @phone = phone
    end

    def send_code
      send_via_twilio if twilio
    end

    def verify_code(code)
      verify_via_twilio(code) if twilio
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
          .create(to: @phone.number, channel: "sms")

      @verification.status == "pending"
    end

    def verify_via_twilio(code)
      @check ||=
        twilio
          .verify
          .v2
          .services(service_sid)
          .verification_checks
          .create(to: @phone.number, code:)

      @check.status == "approved"
    end

    def service_sid
      Masks.setting(:twilio, :service_sid)
    end
  end
end
