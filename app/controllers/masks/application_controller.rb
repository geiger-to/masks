module Masks
  # @visibility private
  class ApplicationController < ActionController::Base
    include Masks::Controller

    before_action :assign_session

    private

    def assign_session
      @session = current_session
      @config = @session.config
      @actor = @session.actor
    end

    def require_sudo(redirect)
      return if current_mask.type == "sudo" && passed?

      flash[:errors] = ["enter a valid password"]

      redirect_to redirect
    end

    def require_anonymous
      redirect_to @config.redirect_url(@session) if @session.passed_checks?(:session)
    end
  end
end
