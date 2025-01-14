module Masks
  module Shims
    class OAuthRequest
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

      class << self
        def call(*args, **opts, &block)
          new(*args, **opts, &block).tap { |c| c.call }
        end
      end

      attr_accessor :client, :scopes, :req, :res, :params, :error

      def initialize(client, params, &block)
        @client = client
        @params = params.stringify_keys
        @block = block
        @app =
          Rack::OAuth2::Server::Authorize.new do |oidc_request, oidc_response|
            client_required! unless client

            @req = oidc_request
            @res = oidc_response

            @scopes = client.scope.minimum(req.scope)

            invalid_reirect_uri! unless req.redirect_uri

            if client.redirect_uris_a.none? && client.autofill_redirect_uri?
              client.redirect_uris = req.redirect_uri.to_s
              client.valid? || invalid_redirect_uri!
            end

            if client.valid_redirect_uri?(req.redirect_uri)
              res.redirect_uri =
                req.verified_redirect_uri = req.redirect_uri.to_s
            else
              invalid_redirect_uri!
            end

            if res.protocol_params_location == :fragment && req.nonce.blank?
              nonce_required!
            end

            response_type =
              Array(req.response_type).collect(&:to_s).sort.join(" ")

            unless client.valid_response_type?(response_type)
              unsupported_response_type!
            end

            unless client.valid_pkce_request?(
                     response_type:,
                     challenge: req.try(:code_challenge),
                     method: req.try(:code_challenge_method),
                   )
              pkce_required!
            end

            @block.call(self) if @block
          end
      end

      def approved?
        !error && @approved
      end

      def denied?
        error
      end

      def denied!
        self.error = "access-denied"
        req.access_denied!
      end

      def original_redirect_uri
        req&.redirect_uri&.to_s
      end

      def redirect_uri
        return unless @response

        _status, header, = @response

        header["Location"]
      end

      def call
        return if error || @response

        begin
          @response ||= @app.call(make_env(params))
        rescue Rack::OAuth2::Server::Authorize::BadRequest => e
          self.error ||= ERRORS.fetch(e.error, e.error.to_s)
        end
      end

      private

      def client_required!
        self.error = "missing-client"
        req.invalid_client!
        req.invalid_request! "nonce required"
      end

      def nonce_required!
        self.error = "missing-nonce"
        req.invalid_request! "nonce required"
      end

      def pkce_required!
        self.error = "invalid-pkce"
        req.invalid_request! "invalid PKCE request"
      end

      def scopes_required!
        self.error = "missing-scopes"
        req.invalid_request! "scopes required"
      end

      def invalid_redirect_uri!
        self.error = "invalid-redirect"
        req.invalid_request!("invalid redirect_uri")
      end

      def unsupported_response_type!
        self.error = "invalid-response"
        req.unsupported_response_type!
      end

      def make_env(params)
        {
          "REQUEST_METHOD" => "GET",
          "REQUEST_PATH" => "/",
          "QUERY_STRING" => params.to_query,
        }
      end
    end
  end
end
