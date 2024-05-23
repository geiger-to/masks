# frozen_string_literal: true

module Masks
  # @visibility private
  module Admin
    class TokensController < BaseController
      section :tokens

      before_action :find_tokens

      rescue_from Pagy::OverflowError do
        redirect_to admin_tokens_path
      end

      def update
        if params[:expire_access_tokens]
          @access_tokens.where(id: params[:expire_access_tokens]).update_all(revoked_at: Time.current)
        end

        redirect_to admin_tokens_path(q: params[:q])
      end

      private

      def param_device
        @param_device ||= if params[:q]
          tenant.devices.find_by(key: params[:q])
        end
      end

      def param_actor
        @param_actor ||= if param_identifier
          tenant.find_actor(identifier: param_identifier.value)
        end
      end

      def param_identifier
        @param_identifier ||= if params[:q]
          tenant.identifier(value: params[:q])
        end
      end

      def param_client
        @param_client ||= if params[:q]
          tenant.clients.find_by(key: params[:q])
        end
      end

      def param_access_tokens
        @param_access_tokens ||= if params[:q]
          tenant.access_tokens.valid.where(token: params[:q])
        end
      end

      def find_tokens
        @access_tokens = if param_device
          tenant.access_tokens.valid.where(device: param_device)
        elsif param_client
          tenant.access_tokens.valid.where(client: param_client)
        elsif param_actor
          param_actor.access_tokens.valid
        elsif param_access_tokens&.any?
          param_access_tokens
        else
          tenant.access_tokens.valid
        end
      end
    end
  end
end
