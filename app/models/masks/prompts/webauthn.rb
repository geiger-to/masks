module Masks
  module Prompts
    class Webauthn < Base
      event "webauthn:add" do
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

      event "webauthn:verify" do
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
              verified_at: Time.now.utc,
              device:,
              actor:,
            )

          if credential.save
            second_factor! :webauthn
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
            allow: actor.webauthn_credentials.map { |c| c.external_id },
          )

        history.extras(webauthn:)

        id_session[:webauthn_challenge] = webauthn.challenge
      end

      event "webauthn:auth" do
        webauthn = WebAuthn::Credential.from_get(updates["credential"])
        credential =
          actor.webauthn_credentials.find_by(external_id: webauthn.id)

        begin
          webauthn.verify(
            id_session[:webauthn_challenge],
            public_key: credential.public_key,
            sign_count: credential.sign_count,
          )

          credential.update!(
            sign_count: webauthn.sign_count,
            verified_at: Time.now.utc,
          )

          second_factor! :webauthn
        rescue WebAuthn::Error => e
          warn! "webauthn-error"
        end
      end
    end
  end
end
