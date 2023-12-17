module Masks
  # @visibility private
  class SessionsController < ApplicationController
    before_action :require_anonymous, only: %i[new create]

    def new
      respond_to { |format| format.html { render(:new) } }
    end

    def create
      flash[:errors] = @session.errors.full_messages

      respond_to { |format| format.html { redirect_to session_path } }
    end

    def destroy
      current_session.cleanup!

      respond_to { |format| format.html { redirect_to session_path } }
    end
  end
end
