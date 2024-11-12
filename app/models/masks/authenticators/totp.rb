module Masks
  module Authenticators
    class Totp < Base
      event "totp:verify" do
        next unless actor

        if actor.second_factor? && !otp_secret.persisted?
          next warn! "invalid-totp"
        end

        if otp_secret.verify_totp(updates["code"])
          second_factor! :totp_code
        else
          warn! "invalid-code:#{updates["code"]}"
        end
      end

      event "totp:name" do
        next unless actor && otp_secret.persisted?

        otp_secret.name = updates["name"]
        otp_secret.save
      end

      private

      def otp_secret
        @otp_secret ||=
          if updates["id"]
            actor.otp_secrets.find_by(public_id: updates["id"])
          else
            Masks::OtpSecret.new(actor:, secret: updates["secret"])
          end
      end
    end
  end
end
