module Masks
  module Prompts
    class Webauthn < SecondFactor
      checks "second-factor"

      event "webauthn:add" do
        next unless actor

        options =
          WebAuthn::Credential.options_for_create(
            attestation: "direct",
            user: {
              id: actor.webauthn_id,
              name: actor.identifier,
            },
            exclude: actor.hardware_keys.pluck(:external_id),
          )

        auth.extras(webauthn: options)
        auth_bag["webauthn_challenge"] = options.challenge
      end

      event "webauthn:verify" do
        webauthn = WebAuthn::Credential.from_create(updates["credential"])

        begin
          webauthn.verify(auth_bag["webauthn_challenge"])
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
            checked! "second-factor", with: :webauthn
          else
            warn! "webauthn-error"
          end
        rescue WebAuthn::Error => e
          warn! "webauthn-error"
        end
      end

      event "webauthn:init" do
        webauthn =
          WebAuthn::Credential.options_for_get(
            allow: actor.hardware_keys.map { |c| c.external_id },
          )

        auth.extras(webauthn:)
        auth_bag["webauthn_challenge"] = webauthn.challenge
      end

      event "webauthn:auth" do
        webauthn = WebAuthn::Credential.from_get(updates["credential"])
        credential = actor.hardware_keys.find_by(external_id: webauthn.id)

        begin
          webauthn.verify(
            auth_bag["webauthn_challenge"],
            public_key: credential.public_key,
            sign_count: credential.sign_count,
          )

          credential.update!(
            sign_count: webauthn.sign_count,
            verified_at: Time.now.utc,
          )

          checked! "second-factor", with: :webauthn
        rescue WebAuthn::Error => e
          warn! "webauthn-error"
        end
      end
    end
  end
end
