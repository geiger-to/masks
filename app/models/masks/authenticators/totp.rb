module Masks
  module Authenticators
    class Totp < Base
      event "totp:add" do
        next unless actor

        otp = Masks::OtpSecret.new(actor:, secret: updates["secret"])

        unless otp.verify_totp(updates["code"])
          warn! "invalid-code:#{updates["code"]}"
        end
      end

      event "totp:name" do
        next unless actor

        otp = actor.otp_secrets.find_by(public_id: updates["id"])
        otp.name = updates["name"]
        otp.save
      end
    end
  end
end
