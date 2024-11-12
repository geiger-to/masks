module Masks
  module Authenticators
    class Phone < Base
      event "phone:verify" do
        next warn! "invalid-phone" unless phone.valid?

        code = updates["code"]

        if phone.verify_code(code)
          second_factor! :sms_code
        else
          warn! "invalid-code:#{code || ""}"
        end
      end

      event "phone:send" do
        next warn! "invalid-phone" unless phone.valid?

        warn! "invalid-phone" unless phone.send_code
      end

      private

      def phone
        @phone ||=
          (
            actor.phones.find_by(number: updates["phone"]) ||
              Masks::Phone.build(actor:, number: updates["phone"])
          )
      end
    end
  end
end
