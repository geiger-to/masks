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
          redirect_uri =
            client.internal? ? oidc.original_redirect_uri : oidc.redirect_uri
          approved = oidc.approved?

          auth.settled!(
            prompt: approved ? "success" : oidc.error,
            redirect_uri:,
            approved:,
            error: oidc.error,
          )
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
    end
  end
end
