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

    delegate :client, :device, to: :history

    attr_reader :history

    def actor
      history.actor if history.authenticated?
    end

    def initialize(history, &block)
      @history = history
      @params = history.oidc_params
      @env = make_env(@params)
      @block = block
      @app =
        Rack::OAuth2::Server::Authorize.new do |req, res|
          invalid_redirect_uri!(req) unless req.redirect_uri

          unless client.redirect_uris_a.any?
            client.redirect_uris = req.redirect_uri.to_s
            client.valid? || invalid_redirect_uri!(req)
          end

          if client.valid_redirect_uri?(req.redirect_uri)
            res.redirect_uri = req.verified_redirect_uri = req.redirect_uri.to_s
          else
            invalid_redirect_uri!(req)
          end

          @scopes = req.scope & client.scopes_a

          scopes_required!(req) if actor && !actor.scopes?(*@scopes)

          if res.protocol_params_location == :fragment && req.nonce.blank?
            nonce_required!(req)
          end

          if client.response_types.include?(
               Array(req.response_type).collect(&:to_s).join(" "),
             )
            if !@validate && actor
              if @approve || history.authorized? || client.auto_consent?
                client.save if client.redirect_uris_changed?

                approved! req, res
                @approved = true
              elsif @deny
                @denied = true
                access_denied!(req)
              end
            end
          else
            unsupported_response_type!
          end
        end
    end

    def approved?
      @approved
    end

    def denied?
      @denied || error
    end

    def access_denied!(req)
      self.error = "access_denied"
      req.access_denied!
    end

    def nonce_required!(req)
      self.error = "nonce_required"
      req.invalid_request! "nonce required"
    end

    def scopes_required!(req)
      self.error = "scopes_required"
      req.invalid_request! "scopes required"
    end

    def invalid_redirect_uri!(req)
      self.error = "invalid_redirect_uri"
      req.invalid_request!("invalid redirect_uri")
    end

    def unsupported_response_type!(req)
      self.error = "unsupported_response_type"
      req.unsupported_response_type!
    end

    def redirect_uri
      return unless @response

      _status, header, = @response

      header["Location"]
    end

    def validate!
      @validate = true
      perform
    end

    def authorize!(event = nil)
      @validate = false
      @approve = event&.include?("approve")
      @deny = event&.include?("deny")

      perform
    end

    def perform
      return if error || @response

      begin
        @response ||= @app.call(@env)
      rescue Rack::OAuth2::Server::Authorize::BadRequest => e
        self.error = e.error.to_s if !error
      end

      history.instance_exec(self, &@block) if @approved || @denied
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
            scopes: scopes.join(" "),
          )

        res.code = authorization_code.code
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

    def make_env(params)
      {
        "REQUEST_METHOD" => "GET",
        "REQUEST_PATH" => "/",
        "QUERY_STRING" => params.to_query,
      }
    end
  end
end
