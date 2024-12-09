module Masks
  module Prompts
    class Phone < SecondFactor
      checks "second-factor"

      def enabled?
        super && install.enabled?(:phones)
      end

      event "phone:verify" do
        next warn! "invalid-phone" unless phone.valid?

        code = updates["code"]

        if phone.verify_code(code)
          checked! "second-factor", with: :phone
        else
          warn! "invalid-code", code
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
