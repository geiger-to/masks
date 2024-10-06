# frozen_string_literal: true
module Masks
  # Manages authorizations for OpenID/OAuth2 requests.
  class OIDCRequest
    attr_accessor :client,
                  :actor,
                  :device,
                  :scopes,
                  :response,
                  :response_type,
                  :authorization_code,
                  :access_token,
                  :id_token,
                  :error

    class << self
      def perform(history, **opts, &block)
        request = new(history, **opts, &block)
        request.perform
        request
      end
    end

    delegate :client, :actor, :device, to: :history

    attr_reader :history

    def initialize(history, **opts, &block)
      @history = history
      @params = history.oidc_params
      @env = make_env(@params)
      @app =
        Rack::OAuth2::Server::Authorize.new do |req, res|
          req.invalid_request!('"redirect_uri" missing') unless req.redirect_uri

          unless client.redirect_uris.any?
            client.redirect_uris = [req.redirect_uri.to_s]
            client.valid? || invalid_redirect_uri!(req)
          end

          res.redirect_uri = req.verify_redirect_uri!(client.redirect_uris)

          @scopes = req.scope & client.scopes

          scopes_required!(req) unless actor&.scopes?(*@scopes)

          if res.protocol_params_location == :fragment && req.nonce.blank?
            nonce_required!(req)
          end

          if client.response_types.include?(
               Array(req.response_type).collect(&:to_s).join(" "),
             )
            if actor
              if opts[:approve] || history.authorized? || client.auto_consent?
                client.save if client.redirect_uris_changed?

                approved! req, res
                @approved = true

                history.instance_exec(self, &block)
              elsif opts[:deny]
                access_denied!(req)
                @denied = true

                history.instance_exec(self, &block)
              end
            end
          else
            req.unsupported_response_type!
          end
        end
    end

    def approved?
      @approved
    end

    def denied?
      @denied || @error
    end

    def access_denied!(req)
      @error = "access_denied"
      req.access_denied!
    end

    def nonce_required!(req)
      @error = "nonce_required"
      req.invalid_request! "nonce required"
    end

    def scopes_required!(req)
      @error = "scopes_required"
      req.invalid_request! "scopes required"
    end

    def invalid_redirect_uri!(req)
      @error = "invalid_redirect_uri"
      req.invalid_request!("invalid redirect_uri")
    end

    def unsupported_response_type!(req)
      @error = "unsupported_response_type"
      req.unsupported_response_type!
    end

    def redirect_uri
      return unless @response

      _status, header, = @response

      header["Location"]
    end

    def perform
      @response ||= @app.call(@env)
    end

    def approved!(req, res)
      response_types = Array(req.response_type)

      if response_types.include? :code
        @authorization_code =
          actor.authorization_codes.create!(
            client:,
            device:,
            actor:,
            redirect_uri: res.redirect_uri,
            nonce: req.nonce,
            scopes:,
          )

        res.code = authorization_code.code
      end

      if response_types.include? :token
        @access_token =
          actor.access_tokens.create!(
            client:,
            device:,
            actor:,
            scopes:,
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

    def make_env(params)
      {
        "REQUEST_METHOD" => "GET",
        "REQUEST_PATH" => "/",
        "QUERY_STRING" => params.to_query,
      }
    end
  end
end
