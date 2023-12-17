module Masks
  # @visibility private
  class RecoveriesController < ApplicationController
    before_action :require_anonymous

    def new
      respond_to { |format| format.html { render(:new) } }
    end

    def create
      respond_to { |format| format.html { redirect_to recover_path } }
    end

    def password
      @recovery = current_session.extra(:recovery)

      respond_to { |format| format.html { render(:password) } }
    end

    def reset
      @recovery = current_session.extra(:recovery)

      flash[:reset] = true if @recovery&.destroyed?
      flash[:errors] = @recovery.errors.full_messages if @recovery && !@recovery&.valid?

      redirect = @recovery ? recover_password_path(token: @recovery.token) : recover_path

      respond_to { |format| format.html { redirect_to redirect } }
    end
  end
end
