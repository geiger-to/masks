# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class ActorsController < BaseController
      section :actors

      before_action :find_actor, only: %i[show create update]

      rescue_from Pagy::OverflowError do
        redirect_to manage_devices_path
      end

      def index
        @pagy, @actors = pagy(actor_model.all)
      end

      def create
        actor =
          signup_access.signup(
            nickname: params[:nickname],
            password: params[:password]
          )

        if actor.valid?
          redirect_to manage_actor_path(actor)
        else
          flash[:errors] = actor.errors.full_messages
          redirect_to manage_actors_path
        end
      end

      def update
        actor_model.transaction do
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
              flash[:info] = "identifier verified"
            end
          elsif params[:unverify_identifier]
            identifier = @actor.identifiers.find_by(value: params[:unverify_identifier])

            if identifier
              identifier.update_attribute(:verified_at, nil)
              flash[:info] = "identifier un-verified"
            end
          elsif params[:remove_identifier]
            identifier = @actor.identifiers.find_by(value: params[:remove_identifier])

            if identifier && @actor.identifiers.count > 1
              identifier.destroy
              flash[:info] = "removed identifier \"#{identifier.value}\""
            end
          elsif params[:add_identifier]
            identifier = masks_config.identifier(key: nil, value: params[:add_identifier])
            identifier.actor = @actor if identifier

            if identifier&.save
              flash[:info] = "identifier added"
            elsif identifier
              flash[:error] = @identifier.errors.full_messages.first
            else
              flash[:error] = 'invalid identifier'
            end
          elsif password_param
            password_access.change_password(password_param, actor: @actor)

            if @actor.valid?
              flash[:info] = "password changed"
            else
              flash[:error] = "invalid password"
            end
          end

          redirect_to manage_actor_path(@actor)
        end

        @actor
      end

      private

      def find_actor
        @actor = actor_model.includes(:identifiers).find_by!(identifiers: {value: params[:actor]})
        @identifiers = @actor.identifiers.all
        @identifier_count = @actor.identifiers.count
      end

      def actor_model
        Masks.configuration.model(:actor)
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
