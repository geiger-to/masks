module Masks
  module Authenticators
    class VerifyEmail < Base
      def enabled?
        return unless Masks.installation.emails?
        return unless client&.require_verified_email?

        true
      end

      event "verified-email:add" do
        next unless needs_verification?

        add_email
      end

      event "verified-email:verify" do
        next unless needs_verification?

        reverify_email
      end

      event "verified-email:verify-code" do
        next unless needs_verification?

        verify_code
      end

      prompt "verify-email" do
        needs_verification?
      end

      def needs_verification?
        return false if authenticating?

        latest_verified_email =
          actor.emails.verified.for_login.order(verified_at: "desc").first
        !latest_verified_email ||
          latest_verified_email.expired_verification?(client)
      end
    end
  end
end
