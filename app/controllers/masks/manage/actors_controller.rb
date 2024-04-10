# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class ActorsController < BaseController
      section :actors

      before_action :find_actor

      def index
        @pagy, @actors = pagy(Masks::Rails::Actor.all)
      end

      def update
        Masks::Rails::Actor.transaction do
          if params[:add_scope]
            @actor.assign_scopes!(params[:add_scope])
            flash[:info] = "added scope"
          elsif params[:remove_scope]
            @actor.remove_scopes!(params[:remove_scope])
            flash[:info] = "removed scope"
          elsif params[:remove_factor2]
            @actor.remove_factor2! if params[:remove_factor2]
            flash[:info] = "removed second factor authentication"
          end

          redirect_to manage_actor_path(@actor)
        end

        @actor
      end

      private

      def find_actor
        @actor = Masks::Rails::Actor.find_by(nickname: params[:actor])
      end
    end
  end
end
