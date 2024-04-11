# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class ActorsController < BaseController
      section :actors

      before_action :find_actor

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
        @actor = actor_model.find_by(nickname: params[:actor])
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
