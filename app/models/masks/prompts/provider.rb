module Masks
  module Prompts
    class Provider < Base
      before_auth { sign_on! if single_sign_on }

      after_auth always: true do
        add_extras if sso_bag && !auth.extras["sso"]
      end

      prompt "sso:link" do
        if sso_bag && sso_bag["accepted"] && authenticated? && !single_sign_on
          add_extras(info: sso_bag.dig("omniauth", "info"))

          true
        end
      end

      event "sso:link" do
        if authenticated? && sso_bag
          sso =
            Masks::SingleSignOn.new(
              key: sso_bag.dig("omniauth", "uid"),
              provider:,
              actor:,
            )

          sso.settings = sso_bag["omniauth"]

          warn! "invalid-sso", prompt: "sso:link" unless sso.save
        end

        self.prompt = "sso:link"

        add_extras
      end

      event "sso:login" do
        sso_bag["accepted"] = true if sso_bag
      end

      prompt "sso:accept" do
        if sso_bag && !sso_bag["accepted"] && !single_sign_on
          add_extras

          true
        end
      end

      event "sso:reset" do
        attempt_bag["sso"] = nil if sso_bag
      end

      prompt "sso" do
        provider && state_bag
      end

      event "sso:request" do
        next unless updates["provider"]

        @provider = client.provider(updates["provider"])

        next unless @provider

        request_phase(provider) if @provider && updates["origin"]
        add_extras(provider)

        self.prompt = "sso"
      end

      event "sso:callback" do
        @provider = updates["provider"]

        callback_phase if provider && state_bag

        add_extras(provider)

        self.prompt = "sso"
      end

      def state_bag
        device_bag&.dig("sso", state_param)
      end

      private

      def provider
        @provider ||=
          if state_bag && state_bag["attempt"] == auth.id
            client.provider(state_bag["provider"])
          else
            sso_provider
          end
      end

      def sso_provider
        @sso_provider ||= (client.provider(sso_bag["provider"]) if sso_bag)
      end

      def add_extras(p = nil, **extras)
        auth.extras(
          provider: provider_json(p || provider),
          phase:,
          sso: sso_json,
          **extras,
        )
      end

      def phase
        state_bag ? "callback" : "request"
      end

      def state_param
        request.GET[:state]&.presence
      end

      def sso_bag
        attempt_bag.dig("sso")
      end

      def single_sign_on
        return unless sso_bag

        @single_sign_on ||=
          provider.single_sign_ons.find_by(key: sso_bag.dig("omniauth", "uid"))
      end

      def sso_json
        return unless sso_bag

        {
          provider: provider_json(sso_provider),
          bag: sso_bag,
          linked: single_sign_on&.present?,
        }
      end

      def request_phase(provider)
        app = provider_app(provider)
        env = make_env(provider, session: {})

        origin =
          begin
            URI(updates["origin"])
          rescue => e
            nil
          end

        return warn! "invalid-origin" unless origin

        status, headers, _ = app.call(env)

        auth.extras(redirect: headers["location"])

        state = env["rack.session"]["omniauth.state"]

        if state
          device_bag["sso"] ||= {}
          device_bag["sso"][state] = {
            "session" => env["rack.session"],
            "attempt" => auth.id,
            "provider" => provider.key,
            "origin" => updates["origin"],
          }
        end
      end

      def callback_phase
        app = provider_app(provider)
        env =
          make_env(
            provider,
            session: state_bag["session"],
            query: request.GET.to_query,
          )

        status, headers, _ = app.call(env)

        omniauth = env["omniauth.auth"]

        attempt_bag["sso"] = {
          "accepted" => single_sign_on&.present?,
          "omniauth" => omniauth&.as_json,
          "provider" => provider.key,
        }

        # Actors that have already linked to a provider are not prompted
        # to re-link accounts. It is assumed this is what they want. Since
        # tokens may be refreshed, the SSO record must be updated automatically.
        sign_on! if single_sign_on

        device_bag["sso"][state_param] = nil
      end

      def make_env(p, session:, query: "")
        {
          "REQUEST_METHOD" => "POST",
          "PATH_INFO" => provider_path(p),
          "QUERY_STRING" => query,
          "rack.session" => session,
        }
      end

      def sign_on!
        self.actor = single_sign_on.actor
        self.identifier = self.actor.identifier

        checked!("credentials", with: :sso)
      end

      def provider_path(p)
        phase == "callback" ? callback_path(p) : request_path(p)
      end

      def callback_path(p)
        "/sso/#{p.key}"
      end

      def request_path(p)
        "/sso/#{p.key}/request"
      end

      def provider_app(p)
        OmniAuth.config.request_validation_phase = nil
        OmniAuth.config.full_host = Masks.url.to_s

        request_path = provider_path(p)
        default_opts = {
          request_path: request_path(p),
          callback_path: callback_path(p),
        }

        OmniAuth::Builder.new do
          provider p.omniauth_strategy,
                   *p.omniauth_args,
                   **p.omniauth_opts.merge(default_opts)

          run { |env| [500, { "content-type" => "text/plain" }, [""]] }
        end
      end

      def provider_json(p, **extras)
        return unless p

        p.slice(:name).merge(id: p.key, type: p.public_type, **extras)
      end
    end
  end
end
