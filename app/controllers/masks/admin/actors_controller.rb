# frozen_string_literal: true

module Masks
  # @visibility private
  module Admin
    class ActorsController < BaseController
      section :actors

      before_action :find_actor, only: %i[show update]

      rescue_from Pagy::OverflowError do
        redirect_to admin_actors_path
      end

      def index
        @pagy, @actors = pagy(tenant.actors.all)
      end

      def create
        actor = tenant.actors.build(signup: true)
        actor.identifiers = tenant.identifiers.map do |key, _|
          tenant.identifier(key:, value: params[key]) if params[key]
        end.compact

        actor.password = params[:password]
        actor.save if actor.valid?

        if actor.save
          redirect_to admin_actor_path(actor)
        else
          flash[:errors] = actor.errors.full_messages
          redirect_to admin_actors_path
        end
      end

      def update
        tenant.actors.transaction do
          if params[:add_scope]
            @actor.assign_scopes!(params[:add_scope])
            flash[:info] = "added scope \"#{params[:add_scope]}\""
          elsif params[:remove_scope]
            @actor.remove_scopes!(params[:remove_scope])
            flash[:info] = "removed scope \"#{params[:remove_scope]}\""
          elsif params[:remove_factor2]
            @actor.remove_factor2!
            flash[:info] = "removed second factor authentication"
          elsif params[:logout]
            @actor.logout!
            flash[:info] = "logged out of all devices"
          elsif params[:verify_identifier]
            identifier = @actor.identifiers.find_by(value: params[:verify_identifier])

            if identifier
              identifier.touch(:verified_at)
              flash[:info] = "#{identifier.value} verified"
            end
          elsif params[:unverify_identifier]
            identifier = @actor.identifiers.find_by(value: params[:unverify_identifier])

            if identifier
              identifier.update_attribute(:verified_at, nil)
              flash[:info] = "#{identifier.value} unverified"
            end
          elsif params[:remove_identifier]
            identifier = @actor.identifiers.find_by(value: params[:remove_identifier])

            if identifier && @actor.identifiers.count > 1
              identifier.destroy
              flash[:info] = "removed \"#{identifier.value}\""
            end
          elsif params[:add_identifier]
            identifier = tenant.identifier(key: nil, value: params[:add_identifier])
            identifier.actor = @actor if identifier

            if identifier&.save
              flash[:info] = "#{identifier.value} added"
            elsif identifier
              flash[:error] = identifier.errors.full_messages.first
            else
              flash[:error] = 'invalid identifier'
            end
          elsif params[:expire_device]
            device = tenant.devices.find_by(key: params[:expire_device])
            tokens = device.access_tokens.valid.where(actor: @actor) if device
            tokens.update_all(revoked_at: Time.current)

            flash[:info] = "\"#{helpers.device_desc(device)}\" logged out"
          elsif params[:expire_client]
            client = tenant.clients.find_by(key: params[:expire_client])
            tokens = client.access_tokens.valid.where(actor: @actor) if client
            tokens.update_all(revoked_at: Time.current)

            flash[:info] = "\"#{client.name}\" revoked"
          elsif password_param
            password_access.change_password(password_param, actor: @actor)

            if @actor.valid?
              flash[:info] = "password changed"
            else
              flash[:error] = "invalid password"
            end
          end

          redirect_to admin_actor_path(@actor)
        end

        @actor
      end

      private

      def find_actor
        @actor = tenant.actors.includes(:identifiers).find_by!(identifiers: {value: params[:actor]})
        @clients = @actor.clients.distinct
        @client_access = @clients.to_h do |client|
          [client.key, client.access_tokens.valid.where(actor: @actor).order(created_at: :desc).first&.created_at]
        end
        @identifiers = @actor.identifiers.all
        @identifier_count = @actor.identifiers.count
        @devices = @actor.devices.distinct.includes(:access_tokens)
        @device_access = @devices.to_h do |device|
          [device.key, device.access_tokens.valid.where(actor: @actor).order(created_at: :desc).first&.created_at]
        end
      end

      def signup_access
        masked_session.access("actor.signup")
      end

      def password_access
        masked_session.access("actor.password")
      end

      def password_param
        params[:change_password]
      end
    end
  end
end
