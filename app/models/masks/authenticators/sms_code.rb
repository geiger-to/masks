module Masks
  module Authenticators
    class Phone < Base
      event "phone:add" do
        next warn! "invalid-phone" unless phone.valid?

        warn! "invalid-phone" unless sms_code.send_code
      end

      event "phone:verify" do
        next warn! "invalid-phone" unless phone.valid?

        code = updates["code"]

        byebug

        unless sms_code.verify_code(code) && phone.save
          warn! "invalid-code:#{code}"
        end
      end

      private

      def sms_code
        @sms_code ||= Masks::SmsCode.new(phone)
      end

      def phone
        @phone ||= actor.phones.build(number: updates["phone"])
      end
    end
  end
end
