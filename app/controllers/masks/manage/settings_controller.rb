# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class SettingsController < BaseController
      section :settings

      before_action :assign_settings

      def upsert
        saved = false
        names = params.keys & model::NAMES
        names.each do |name|
          setting = model.find_or_initialize_by(name:)
          setting.value = params[name].presence

          if !setting.valid? || setting.value == @settings[name]
            next
          end

          setting.save!
          saved = true
        end

        if saved
          flash[:info] = 'settings updated'
        else
          flash[:errors] = 'settings could not be saved'
        end

        redirect_back fallback_location: manage_path
      end

      private

      def model
        Masks.model(:setting)
      end

      def assign_settings
        @settings = Masks.settings
      end
    end
  end
end
