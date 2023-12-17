module Masks
  # @visibility private
  class RecoveriesController < ApplicationController
    before_action :redirect_if_logged_in, only: %i[new]

    def new
      respond_to { |format| format.html { render(:new) } }
    end

    def create
      flash[:recovery] = true

      respond_to { |format| format.html { redirect_to recover_path } }
    end

    def password
      @recovery = masked_session.extra(:recovery)

      respond_to { |format| format.html { render(:password) } }
    end

    def reset
      @recovery = masked_session.extra(:recovery)

      flash[:reset] = true if @recovery&.destroyed?
      flash[:errors] = @recovery.errors.full_messages if @recovery &&
        !@recovery&.valid?

      redirect =
        @recovery ? recover_password_path(token: @recovery.token) : recover_path

      respond_to { |format| format.html { redirect_to redirect } }
    end

    private

    def redirect_if_logged_in
      redirect_to Masks.configuration.site_links[:root] if current_actor
    end
  end
end
