module Masks
  module Prompts
    class VerifyEmail < Base
      checks "verified-email"

      def enabled?
        Masks.installation.emails?
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

        checked! "verified-email" if verify_code
      end

      prompt "verify-email" do
        next true if needs_verification?

        checked! "verified-email" unless checked?("verified-email")

        false
      end

      private

      def needs_verification?
        latest_verified_email =
          actor.emails.verified.for_login.order(verified_at: "desc").first
        !latest_verified_email ||
          latest_verified_email.expired_verification?(client)
      end
    end
  end
end
