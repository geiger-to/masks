module Masks
  module Prompts
    class LoginLink
      include Masks::Prompt

      match { client.allow_login_links? && on_first_factor? }

      around_entry do |block|
        email_bag.current = identifier

        block.call

        if active_login_link?
          session.bag(:login_links).current = active_login_link
        end
      end

      event "login-link:start" do
        if !active_login_link? || !active_login_link
          expiry = client.expires_at(:login_link)
          data = { "sent" => true }

          if login_email
            @active_login_link =
              Masks::LoginLink.new(
                log_in: true,
                email: login_email,
                client:,
                device:,
                path:,
                params:,
                expires_at: expiry,
              )
            @active_login_link.save_and_deliver if active_links&.none?

            data["link_id"] = @active_login_link.id
          end

          email_bag.overwrite(data, expiry:)
        end

        self.prompt = "login-code"
      end

      event "login-link:password" do
        next unless client.allow_passwords?

        self.prompt = "first-factor"
      end

      event "login-link:verify", if: :active_login_link do
        unless active_login_link.deliverable?
          next warn!("invalid-code", code, prompt: "login-code")
        end

        active_login_link.authenticated!

        checked!(Entry::FACTOR1, with: :login_link)

        email_bag.expire

        sibling(:reset_password).requested! if updates["resetPassword"]
      end

      prompt "login-link", if: :active_login_link? do
        request.GET[:login_link]&.present? && active_login_link
      end

      private

      def email_bag
        session.bag(:login_link_emails)
      end

      def active_login_link?
        @active_login_link || email_bag["sent"]
      end

      def active_login_link
        @active_login_link ||=
          begin
            id = email_bag["link_id"] || request.GET[:login_link]

            if id
              Masks::LoginLink.for_login.active.find_by(id:)
            else
              Masks::LoginLink.new(
                client:,
                device:,
                actor:,
                expires_at: email_bag.expiry,
              )
            end
          end
      end

      def login_email
        @login_email ||=
          if actor&.persisted?
            actor.emails.for_login.find_by(address: identifier) ||
              actor.login_email
          end
      end

      def active_links
        @active_links ||=
          if actor&.persisted?
            actor.login_links.active.for_login.where(client:, device:)
          end
      end
    end
  end
end
