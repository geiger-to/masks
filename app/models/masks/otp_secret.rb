module Masks
  class OtpSecret < ApplicationRecord
    self.table_name = "masks_otp_secrets"

    belongs_to :actor

    validates :secret, presence: true, uniqueness: true
    validates :public_id, presence: true, uniqueness: true

    after_initialize :generate_defaults

    def verify_totp(code)
      return false unless valid?

      verified = totp.verify(code, after: verified_at)

      if verified
        self.verified_at = Time.now.utc
        self.save
      end
    end

    def svg(**opts)
      if uri
        qrcode = RQRCode::QRCode.new(uri)
        qrcode.as_svg(**opts)
      end
    end

    def totp
      ROTP::TOTP.new(secret, issuer: Masks.name) if secret
    end

    def uri
      totp.provisioning_uri(actor.uuid) if totp && actor
    end

    private

    def generate_defaults
      self.public_id ||= SecureRandom.uuid
      self.secret ||= ROTP::Base32.random
    end
  end
end
