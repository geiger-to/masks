module Masks
  module Credentials
    class OneTimeCode < Masks::Credential
      include Factor2

      private

      def param
        :one_time_code
      end

      def secret
        actor&.totp_secret
      end

      def verify(code)
        valid_code?(code, self.secret)
      end

      def valid_code?(code, secret)
        if code && secret
          actor.totp.verify(code)
        else
          false
        end
      rescue OpenSSL::HMACError
        false
      end
    end
  end
end
