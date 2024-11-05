module Masks
  module Authenticators
    class LoginLink < Base
      def enabled?
        Masks.installation.emails? && client.allow_login_links? && id_session
      end

      def prepare
        history.login_link =
          (
            if valid_link?
              Masks::LoginLink.new(
                expires_at: Time.parse(id_session[:login_link_expires_at]),
              )
            else
              nil
            end
          )
      end

      prompt "login-link" do
        next unless authenticating?

        history.login_link =
          active_links&.find_by(code: request.params[:login_code])
      end

      prompt "login-code" do
        next unless authenticating?

        valid_link?
      end

      event "login-link:password" do
        next unless authenticating? && client.allow_passwords?

        self.prompt = "credential"
      end

      event "login-link:authenticate" do
        email =
          actor.emails.for_login.find_by(address: history.identifier) ||
            actor&.login_email
        link = Masks::LoginLink.new(history: history, log_in: true, email:)
        link.save_and_deliver if active_links&.none?

        if !valid_link? || link.persisted?
          id_session[
            :login_link_expires_at
          ] = client.login_link_expires_at.iso8601
        end

        self.prompt = "login-code"

        history.login_link = link if link.persisted? || !history.login_link
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
        return false unless id_session

        time = id_session[:login_link_expires_at]
        expired = expired_time?(time)

        if time && expired
          warn!("expired-login-link")
          id_session[:login_link_expires_at] = nil
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

        authenticated!(client.auth_via_login_link_expires_at)

        id_session[:login_link_expires_at] = nil
        auth_session[:reset_password] = true if updates["resetPassword"] &&
          client.allow_passwords?

        true
      end
    end
  end
end
