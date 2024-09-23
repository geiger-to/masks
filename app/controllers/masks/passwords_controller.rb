# frozen_string_literal: true

module Masks
  # @visibility private
  class PasswordsController < ApplicationController
    before_action only: %i[update] do
      require_sudo(password_path)
    end

    def edit
      respond_to { |format| format.html { render(:edit) } }
    end

    def update
      if password_param
        current_access.change_password(password_param)

        flash[:errors] = @actor.errors.full_messages unless @actor.valid?
      end

      respond_to { |format| format.html { redirect_to password_path } }
    end

    private

    def password_param
      params.dig(:password, :change)
    end
  end
end
