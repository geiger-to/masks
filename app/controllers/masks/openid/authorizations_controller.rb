# frozen_string_literal: true
module Masks
  module OpenID
    class AuthorizationsController < ApplicationController
      before_action :require_openid

      rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
        @error = e

        render :error, status: e.status
      end

      def new
        authorize
      end

      def create
        authorize approved: params[:approve]
      end

      private

      def require_openid
        render_not_found unless masks_tenant.openid?
      end

      def authorization
        @authorization ||= Masks::Requests::AuthorizationRequest.new(request)
      end

      def authorize(**opts)
        # TODO: support incoming id_token request object + max_age parameter
        @authorization = AuthorizationRequest.perform(request.env, **opts)

        _status, header, = @authorization.response

        if header["WWW-Authenticate"].present?
          headers["WWW-Authenticate"] = header["WWW-Authenticate"]
        end

        if header["Location"]
          return redirect_to header["Location"], allow_other_host: true
        end

        unless @authorization.actor
          session[:return_to] = request.url

          return redirect_to session_path
        end

        render :new
      end
    end
  end
end
