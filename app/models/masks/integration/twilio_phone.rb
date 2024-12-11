module Masks
  module Integration
    class TwilioPhone < BasePhone
      def notify
        @verification ||=
          twilio
            .verify
            .v2
            .services(service_sid)
            .verifications
            .create(to: phone.number, channel: "sms")

        @verification.status == "pending"
      end

      def verify(code)
        @check ||=
          twilio
            .verify
            .v2
            .services(service_sid)
            .verification_checks
            .create(to: phone.number, code:)

        @check.status == "approved"
      end

      private

      def twilio
        account_sid = Masks.setting(:integration, :twilio, :account_sid)
        auth_token = Masks.setting(:integration, :twilio, :auth_token)

        @twilio ||= Twilio::REST::Client.new(account_sid, auth_token)
      end

      def service_sid
        Masks.setting(:integration, :twilio, :service_sid)
      end
    end
  end
end
