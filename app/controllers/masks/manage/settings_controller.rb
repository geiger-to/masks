# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class SettingsController < BaseController
      section :settings

      def index
        @settings = Masks.settings
      end

      def upsert
        setting = model.find_or_initialize_by(name: params[:name])
        setting.value = params[:value]

        if setting.save
          flash[:saved] = setting.name
        else
          flash[:errors] = setting.errors.full_messages
        end

        redirect_to manage_settings_path
      end

      private

      def model
        Masks.model(:setting)
      end
    end
  end
end
