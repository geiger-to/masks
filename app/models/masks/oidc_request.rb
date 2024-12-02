# frozen_string_literal: true
module Masks
  # Manages authorizations for OpenID/OAuth2 requests.
  class OIDCRequest
    attr_accessor :scopes,
                  :response,
                  :response_type,
                  :authorization_code,
                  :access_token,
                  :id_token,
                  :error,
                  :req,
                  :res

    delegate :client, :device, to: :prompt

    attr_reader :prompt

    ERRORS = { unsupported_response_type: "invalid-response" }

    class << self
      def update(prompt, &block)
        oidc = new(prompt, &block)
        oidc.update!
        oidc
      end
    end

    def initialize(prompt, &block)
      @prompt = prompt
      @params = prompt.params
      @env = make_env(@params)
      @block = block
      @app =
        Rack::OAuth2::Server::Authorize.new do |oidc_request, oidc_response|
          self.req = oidc_request
          self.res = oidc_response

          @scopes = client.scope.minimum(req.scope)

          invalid_redirect_uri! unless req.redirect_uri

          if client.redirect_uris_a.none? && client.autofill_redirect_uri?
            client.redirect_uris = req.redirect_uri.to_s
            client.valid? || invalid_redirect_uri!
          end

          if client.valid_redirect_uri?(req.redirect_uri)
            res.redirect_uri = req.verified_redirect_uri = req.redirect_uri.to_s
          else
            invalid_redirect_uri!
          end

          if res.protocol_params_location == :fragment && req.nonce.blank?
            nonce_required!
          end

          if client.response_types.include?(
               Array(req.response_type).collect(&:to_s).join(" "),
             )
            prompt.instance_exec(self, &@block)
          else
            unsupported_response_type!
          end
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

    def update!
      return if error || @response

      begin
        @response ||= @app.call(@env)
      rescue Rack::OAuth2::Server::Authorize::BadRequest => e
        self.error ||= ERRORS.fetch(e.error, e.error.to_s)
      end
    end

    def validate_scopes!(actor)
      scopes_required! if !actor.scopes?(*@scopes)
    end

    def approved!(actor)
      @approved = true

      client.save if client.redirect_uris_changed?

      response_types = Array(req.response_type)

      if response_types.include? :code
        res.code =
          if client.internal?
            prompt.state.attempt_id
          else
            @authorization_code =
              actor.authorization_codes.create!(
                client:,
                device:,
                actor:,
                redirect_uri: res.redirect_uri,
                nonce: req.nonce,
                scopes: scopes.join(" "),
              )

            authorization_code.code
          end
      end

      if response_types.include? :token
        @access_token =
          actor.access_tokens.create!(
            client:,
            device:,
            actor:,
            scopes: scopes.join(" "),
            authorization_code: @authorization_code,
          )

        res.access_token = access_token.to_bearer_token
      end

      if response_types.include? :id_token
        @id_token =
          actor.id_tokens.create!(client:, device:, actor:, nonce: req.nonce)

        res.id_token =
          id_token.to_jwt(
            code: (res.respond_to?(:code) ? res.code : nil),
            access_token:
              (res.respond_to?(:access_token) ? res.access_token : nil),
          )
      end

      res.approve!
    end

    private

    def nonce_required!
      self.error = "missing-nonce"
      req.invalid_request! "nonce required"
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
