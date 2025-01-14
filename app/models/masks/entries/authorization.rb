module Masks
  module Entries
    class Authorization < Masks::Entry
      PARAMS = %w[
        client_id
        response_type
        grant_type
        redirect_uri
        code_challenge
        code_challenge_method
        login_hint
        prompt
        scope
        state
        nonce
      ]

      def session_lifetime
        client.expires_at(:authorization)
      end

      def client
        @client ||=
          if raw_params["client_id"]
            Masks::Client.find_by!(key: raw_params["client_id"])
          end
      end

      def params
        @params ||=
          client
            .oidc_params(raw_params.permit(*PARAMS).to_h.stringify_keys)
            .sort_by { |k, _| k.to_s }
            .to_h
      end

      def enter
        session.bag(:entries)[:path] = session.rails_request.path
        session.bag(:entries)[:params] = params

        oauth_request
      end
    end
  end
end
