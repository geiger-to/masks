# frozen_string_literal: true

module Masks
  # @visibility private
  class ApplicationController < ActionController::Base
    include Masks::Controller
    include Pagy::Backend

    before_action :assign_session

    skip_before_action :verify_authenticity_token, if: :json_request?

    protect_from_forgery with: :exception

    private

    def json_request?
      request.format.symbol == :json
    end

    def assign_session
      @session = masked_session
      @config = @session.config
      @actor = @session.actor
    end

    def require_sudo(redirect)
      return if current_mask.type == "sudo" && passed?

      flash[:errors] = ["enter a valid password"]

      redirect_to redirect
    end
  end
end
