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
          @access_tokens.where(id: params[:expire_access_tokens]).update_all(
            revoked_at: Time.current
          )
        end

        redirect_to admin_tokens_path(q: params[:q])
      end

      private

      def search_query
        return {} unless params[:q]

        @search_query ||=
          begin
            args = {}

            strings = params[:q].split
            strings.each do |str|
              case str
              when /device:.+/
                args[:device] = str.split(":").last
              when /client:.+/
                args[:client] = str.split(":").last
              when /actor:.+/
                value = str.split(":").last
                if (id = tenant.identifier(value:))
                  args[:identifier] = id
                end
              end
            end

            args
          end
      end

      def client_query
        search_query[:client]
      end

      def param_device
        @param_device ||=
          if search_query[:device]
            tenant.devices.find_by(key: search_query[:device])
          end
      end

      def param_actor
        @param_actor ||=
          if search_query[:identifier]
            tenant.find_actor(identifier: search_query[:identifier].value)
          end
      end

      def param_client
        @param_client ||=
          if search_query[:client]
            tenant.clients.find_by(key: search_query[:client])
          end
      end

      def find_tokens
        @access_tokens =
          if param_device
            tenant.access_tokens.valid.where(device: param_device)
          elsif param_client
            tenant.access_tokens.valid.where(client: param_client)
          elsif param_actor
            param_actor.access_tokens.valid
          elsif params[:q] && !params[:q].include?(":")
            tenant.access_tokens.valid.where(
              "token LIKE ?",
              "#{Masks::AccessToken.sanitize_sql_like(params[:q])}%"
            )
          else
            tenant.access_tokens.valid
          end
      end
    end
  end
end
