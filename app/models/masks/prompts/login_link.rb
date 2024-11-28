module Masks
  module Prompts
    class LoginLink < Base
      def enabled?
        client.allow_login_links? && identifier && checking?("credentials")
      end

      after_auth do
        next unless auth_bag

        # Ensure actors that don't exist still appear to receive a login link
        # (with a real expiration time).
        self.login_link ||=
          unless Masks.time.expired?(auth_bag[:login_link_expires_at])
            Masks::LoginLink.new(
              expires_at: Time.parse(auth_bag[:login_link_expires_at]),
            )
          end
      end

      prompt "login-link" do
        auth.login_link =
          active_links&.find_by(code: request.params[:login_code])
      end

      prompt "login-code" do
        valid_link? && !checked?("credentials")
      end

      event "login-link:password" do
        next unless client.allow_passwords?

        self.prompt = "credentials"
      end

      event "login-link:authenticate" do
        email =
          actor.emails.for_login.find_by(address: identifier) ||
            actor.login_email
        link = Masks::LoginLink.new(auth:, log_in: true, email:)
        link.save_and_deliver if active_links&.none?

        if !valid_link? || link.persisted?
          auth_bag[:login_link_expires_at] = client.expires_at(
            :login_link,
          ).iso8601
        end

        self.prompt = "login-code"

        auth.login_link = link if link.persisted? || !auth.login_link
      end

      event "login-link:verify" do
        code = updates["code"] || request.params[:login_code]
        link = active_links&.find_by(code:) if code

        unless verify_link(link)
          warn! "invalid-code" if code
        end
      end

      private

      def valid_link?
        time = auth_bag[:login_link_expires_at]
        expired = Masks.time.expired?(time)

        if time && expired
          warn!("expired-login-link")
          auth_bag[:login_link_expires_at] = nil
        end

        !expired
      end

      def active_links
        if actor&.persisted?
          actor.login_links.active.where(log_in: true, client:, device:)
        end
      end

      def verify_link(link)
        return false unless link

        link.authenticated!

        checked!("credentials", with: :login_link)

        auth_bag[:login_link_expires_at] = nil
        auth_bag[:reset_password] = true if updates["resetPassword"] &&
          client.allow_passwords?

        true
      end
    end
  end
end
