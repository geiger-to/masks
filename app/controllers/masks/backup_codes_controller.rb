# frozen_string_literal: true

module Masks
  # @visibility private
  class BackupCodesController < ApplicationController
    require_mask type: :session, only: :new
    before_action only: %i[create] do
      require_sudo(backup_codes_path)
    end

    def new
      respond_to { |format| format.html { render(:new) } }
    end

    def create
      if create_params[:reset]
        @actor.saved_backup_codes_at = nil
        @actor.backup_codes = nil
        @actor.save
      elsif create_params[:enable]
        @actor.saved_backup_codes_at = Time.current
        @actor.save
      end

      respond_to { |format| format.html { redirect_to backup_codes_path } }
    end

    private

    def create_params
      params.require(:backup_codes).permit(:reset, :enable)
    end
  end
end
