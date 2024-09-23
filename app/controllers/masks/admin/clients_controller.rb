# frozen_string_literal: true

module Masks
  # @visibility private
  module Admin
    class ClientsController < BaseController
      section :clients

      before_action :find_client, only: %i[show update destroy]

      helper_method :all_profiles

      rescue_from Pagy::OverflowError do
        redirect_to admin_clients_path
      end

      def index
        @pagy, @clients =
          pagy(Masks::Client.all.order(created_at: :desc))
      end

      def create
        client =
          tenant.clients.build(name: params[:name])

        if client.save
          redirect_to admin_client_path(client)
        else
          flash[:errors] = client.errors.full_messages

          redirect_to admin_clients_path
        end
      end

      def update
        Masks::Client
          .transaction do
            if params[:add_scope]
              @client.assign_scopes!(params[:add_scope])
              flash[:info] = "added scope"
            elsif params[:remove_scope]
              @client.remove_scopes!(params[:remove_scope])
              flash[:info] = "removed scope"
            else
              update_client
              flash[:info] = "updated \"#{@client.name}\""
            end

            redirect_to admin_client_path(@client)
          end
      end

      def destroy
        @client.destroy

        flash[:destroyed] = @client.name

        redirect_to admin_clients_path
      end

      private

      def update_client
        @client.name = params[:name]
        @client.secret = params[:secret]
        @client.consent = params[:consent]
        @client.redirect_uris = params[:redirect_uris].split("\n")
        @client.subject_type = params[:subject_type]
        @client.code_expires_in = params[:code_expires_in]
        @client.id_token_expires_in = params[:id_token_expires_in]
        @client.access_token_expires_in = params[:access_token_expires_in]
        @client.save

        return if @client.valid?

        flash[:errors] = @client.errors.full_messages
      end

      def find_client
        @client = Masks::Client.find_by(key: params[:id])
      end

      def all_profiles
        @all_profiles ||= tenant.profiles
      end
    end
  end
end
