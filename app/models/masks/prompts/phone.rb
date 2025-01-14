module Masks
  module Prompts
    class Phone
      include Masks::Prompt

      KEY = "phone_verifications"

      match { client.allow_phones? && changeable_2fa? }

      before_entry do
        session.bag(
          :phone_verifications,
          parent: :attempts,
          expiry: 5.minutes.from_now,
        )
      end

      event "phone:send" do
        session.bag(:phone_verifications).current = phone.number

        next warn! "invalid-phone" if !phone.valid?
        next if phone_notified? && !updates.dig("create", "resend")
        next warn! "invalid-phone" unless phone.send_code

        session.bag(:phone_verifications)["sent"] = true
      end

      event "phone:create", if: :change_2fa? do
        verify_phone_with_code(phone, updates.dig("create", "code"))
        expire_notification(phone) unless auth.warnings
      end

      event "phone:verify", if: :on_2fa? do
        verify_phone
      end

      event "phone:delete", if: :change_2fa? do
        verified_phone.destroy

        expire_notification(verified_phone)
      end

      private

      def phone
        @phone ||=
          Masks::Phone.build(actor:, number: updates.dig("create", "number"))
      end

      def phone_notified?
        session.bag(:phone_verifications)["sent"]
      end

      def expire_notification(phone = nil)
        phone ||= self.phone

        session.bag(:phone_verifications).current = phone.number
        session.bag(:phone_verifications).clear
      end
    end
  end
end
