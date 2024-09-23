# frozen_string_literal: true

module Masks
  # @visibility private
  module Admin
    class BaseController < ApplicationController
      layout "masks/admin"

      class << self
        def section(section, subsection = nil)
          before_action do
            @section = [section, subsection].compact.join('-')
          end
        end
      end

      helper_method :current_actor, :section, :admin_client
      before_action :require_admin_client
      before_action :redirect_to_login, unless: :logged_in?

      before_action do
        device.actor = current_actor
        device.client = admin_client
      end

      attr_accessor :section

      private

      def client
        @client ||= admin_client
      end

      def admin_client
        @admin_client ||= tenant.admin
      end

      def version
        Masks::VERSION
      end

      def require_admin_client
        render_not_found unless admin_client
      end

      def code_key
        "#{tenant_key}:manage:code"
      end

      def token_key
        "#{tenant_key}:manage:token"
      end

      def current_actor
        access_token&.actor
      end

      def access_token
        @access_token ||= begin
          access_token = authorization&.access_token

          if access_token
            session[token_key] = access_token.token
            session[code_key] = nil
          elsif session[token_key]
            access_token = tenant.access_tokens.valid.find_by(token: session[token_key])
          end

          access_token
        end
      end

      def authorization
        if params[:code]
          session[code_key] = params[:code]
        end

        return unless (code = session[code_key])

        @authorization ||= tenant.authorizations.valid.find_by(code:)
      end

      def logged_in?
        current_actor.present?
      end

      def redirect_to_login
        if params[:error]
          return render 'masks/admin/error', locals: { anon: true }
        end

        if session[token_key]
          return render 'masks/admin/expired', locals: { anon: true }
        end

        redirect_to session_path(
          client_id: admin_client.key,
          response_type: 'code',
          redirect_uri: admin_url,
          scope: 'openid masks:manage'
        )
      end
    end
  end
end
