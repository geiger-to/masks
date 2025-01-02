module Masks
  module Prompts
    class OIDC < Base
      checks "client-consent"

      around_auth do |auth, block|
        oidc =
          Masks::OIDCRequest.update(self) do |oidc|
            auth.scopes = oidc.scopes

            block.call

            if actor && checking?("client-consent") || authenticated?
              oidc.validate_scopes!(actor)
            end

            next unless authenticated?

            check = auth.check("client-consent")

            if check.denied?
              oidc.denied!
            elsif check.approved? || client.auto_consent?
              approved!
              oidc.approved!(actor)
            end
          end

        if oidc.redirect_uri || oidc.error
          auth.settled!(
            redirect_uri:
              client.internal? ? oidc.original_redirect_uri : oidc.redirect_uri,
            prompt: oidc.approved? ? "success" : oidc.error,
            approved: oidc.approved?,
            error: oidc.error,
            token: oidc.token,
          )

          auth.client_bag[
            "current_token"
          ] = oidc.internal_token.secret if oidc.internal_token
        end
      end

      prompt "authorize" do
        approved! if client.auto_consent?

        checking?("client-consent")
      end

      event "authorize" do
        approved!
      end

      event "deny" do
        checked! "client-consent", denied: true
      end

      def approved!
        checked! "client-consent", approved: true
      end

      def manager
        if manager_token&.actor&.scope?(Masks::Scoped::MANAGE)
          manager_token&.actor
        end
      end

      private

      def manager_token
        @manager_token ||=
          if secret =
               client_bag(Masks::Client.manage)&.fetch("current_token", nil)
            token = Masks::Token.usable.find_by(secret:)
            client_bag(Masks::Client.manage)["current_token"] = nil unless token
            token
          end
      end
    end
  end
end
