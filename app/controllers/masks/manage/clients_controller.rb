# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class ClientsController < BaseController
      section :clients

      before_action :find_client, only: %i[show update destroy]

      rescue_from Pagy::OverflowError do
        redirect_to manage_clients_path
      end

      def index
        @pagy, @clients =
          pagy(Masks::Rails::OpenID::Client.all.order(created_at: :desc))
      end

      def create
        client =
          Masks.configuration.model(:openid_client).new(name: params[:name])

        if client.save
          redirect_to manage_client_path(client)
        else
          flash[:errors] = client.errors.full_messages

          redirect_to manage_clients_path
        end
      end

      def update
        Masks
          .configuration
          .model(:openid_client)
          .transaction do
            if params[:add_scope]
              @client.assign_scopes!(params[:add_scope])
              flash[:info] = "added scope"
            elsif params[:remove_scope]
              @client.remove_scopes!(params[:remove_scope])
              flash[:info] = "removed scope"
            else
              update_client
            end

            redirect_to manage_client_path(@client)
          end
      end

      def destroy
        @client.destroy

        flash[:destroyed] = @client.name

        redirect_to manage_clients_path
      end

      private

      def update_client
        @client.name = params[:name]
        @client.secret = params[:secret]
        @client.consent = params[:consent]
        @client.redirect_uris = params[:redirect_uris].split("\n")
        @client.subject_type = params[:subject_type]
        @client.code_expires_in = params[:code_expires_in]
        @client.token_expires_in = params[:token_expires_in]
        @client.refresh_expires_in = params[:refresh_expires_in]
        @client.save

        return if @client.valid?

        flash[:errors] = @client.errors.full_messages
      end

      def find_client
        @client =
          Masks.configuration.model(:openid_client).find_by(key: params[:id])
      end
    end
  end
end
