module Masks
  module Prompts
    class Webauthn
      include Masks::Prompt

      match { client.allow_webauthn? && changeable_2fa? }

      event "webauthn:register" do
        options =
          WebAuthn::Credential.options_for_create(
            attestation: "direct",
            user: {
              id: actor.webauthn_id,
              name: actor.identifier,
            },
            exclude: actor.hardware_keys.pluck(:external_id),
          )

        extras(webauthn: options)

        bag["webauthn_registration"] = options.challenge
      end

      event "webauthn:create", if: :change_2fa? do
        webauthn = WebAuthn::Credential.from_create(updates["create"])

        begin
          webauthn.verify(bag["webauthn_registration"])
          credential =
            Masks::HardwareKey.new(
              name: Masks::Fido.aaguid_name(webauthn.response.aaguid),
              aaguid: webauthn.response.aaguid,
              external_id: webauthn.id,
              public_key: webauthn.public_key,
              sign_count: webauthn.sign_count,
              verified_at: Time.now.utc,
              actor:,
            )

          if credential.save
            checked! Entry::FACTOR2, with: :webauthn
          else
            warn! "webauthn-error"
          end
        rescue WebAuthn::Error => e
          warn! "webauthn-error"
        end
      end

      event "webauthn:challenge" do
        webauthn =
          WebAuthn::Credential.options_for_get(
            allow: actor.hardware_keys.map { |c| c.external_id },
          )

        extras(webauthn:)
        bag["webauthn_challenge"] = webauthn.challenge
      end

      event "webauthn:verify", if: :on_2fa? do
        verify_webauthn
      end

      event "webauthn:delete", if: :change_2fa? do
        if updates["delete"]
          actor
            .hardware_keys
            .find_by(external_id: updates.dig("delete", "id"))
            &.destroy
        end
      end

      private

      def bag
        session.bag(:entries)
      end
    end
  end
end
