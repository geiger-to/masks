# frozen_string_literal: true

module Masks
  # @visibility private
  class ApplicationController < ActionController::Base
    include Masks::Controller
    include Pagy::Backend

    before_action :assign_session

    skip_before_action :verify_authenticity_token #, if: :json_request?

    # protect_from_forgery with: :exception

    helper_method :masks_settings, :dark_mode?, :dark_mode_allowed?, :theme

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def theme
      dark_mode? ? masks_settings['dark_mode.theme'] : masks_settings['theme']
    end

    def dark_mode_allowed?
      masks_settings['dark_mode.theme']&.present?
    end

    def dark_mode?
      dark_mode_allowed? ? cookies[:default_theme] == 'dark' : false
    end

    def json_request?
      request.format.symbol == :json
    end

    def assign_session
      @session = masked_session
      @config = @session.config
      @actor = @session.actor
    end

    def render_not_found
      render 'masks/404', status: :not_found
    end

    def require_sudo(redirect)
      return if current_mask.type == "sudo" && passed?

      flash[:errors] = ["enter a valid password"]

      redirect_to redirect
    end
  end
end
