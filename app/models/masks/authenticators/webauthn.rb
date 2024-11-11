module Masks
  module Authenticators
    class Webauthn < Base
      event "webauthn:onboard" do
        next unless actor

        options =
          WebAuthn::Credential.options_for_create(
            attestation: "direct",
            user: {
              id: actor.webauthn_id,
              name: actor.identifier,
            },
            exclude: actor.webauthn_credentials.pluck(:external_id),
          )

        history.extras(webauthn: options)

        id_session[:webauthn_challenge] = options.challenge
      end

      event "webauthn:credential" do
        webauthn = WebAuthn::Credential.from_create(updates["credential"])

        begin
          webauthn.verify(id_session[:webauthn_challenge])
          credential =
            Masks::WebauthnCredential.new(
              name: Masks::Fido.aaguid_name(webauthn.response.aaguid),
              aaguid: webauthn.response.aaguid,
              external_id: webauthn.id,
              public_key: webauthn.public_key,
              sign_count: webauthn.sign_count,
              device:,
              actor:,
            )

          warn! "webauthn-error" unless credential.save
        rescue WebAuthn::Error => e
          warn! "webauthn-error"
        end
      end
    end
  end
end
