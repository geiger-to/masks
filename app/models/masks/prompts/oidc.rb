module Masks
  module Prompts
    class OIDC < Base
      checks "client-consent"

      around_update prepend: true do |auth, block|
        oidc =
          Masks::OIDCRequest.update(self) do |oidc|
            auth.scopes = oidc.scopes

            block.call

            next unless authenticated?

            check = auth.check("client-consent")

            if check.denied?
              oidc.denied!
            elsif check.approved? || client.auto_consent?
              oidc.approved!(actor)
            end
          end

        if oidc.redirect_uri || oidc.error
          auth.settled!(
            redirect_uri: oidc.redirect_uri,
            prompt: oidc.approved? ? "success" : oidc.error,
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
