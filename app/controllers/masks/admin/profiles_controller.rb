# frozen_string_literal: true

module Masks
  # @visibility private
  module Admin
    class ProfilesController < BaseController
      section :profiles

      before_action :find_profile, only: %i[show update]

      def index
        @profiles = tenant.profiles.order(name: :asc)
      end

      def find_profile
        @profile = tenant.profiles.find_by(key: params[:id])
        @clients = @profile.clients
        @settings = {}
      end

      def update
        # settings_h = params.require(:settings).permit(
        #   :name,
        #   :url,
        #   :logo,
        #   :theme,
        #   :background,
        #   :favicon,
        #   signups: [
        #     :enabled,
        #   ],
        #   nickname: [
        #     :enabled,
        #     :signups,
        #     :prefix,
        #     :minimum,
        #     :maximum,
        #   ],
        #   email: [
        #     :enabled,
        #     :signups,
        #   ],
        #   phone: [
        #     :enabled,
        #     :signups,
        #   ],
        #   dark_mode: [
        #     :name,
        #     :logo,
        #     :theme,
        #     :background
        #   ]
        # )[:settings].to_h

        @profile.settings = @profile.settings.deep_merge(param_settings)

        if @profile.save
          flash[:info] = 'settings updated'
        else
          flash[:error] = @profile.errors.full_messages.first
        end

        redirect_to admin_profile_path(@profile, tab: params[:tab])
      end

      def param_settings
        @param_settings ||= begin
          hash = {}
          names = params[:settings].keys & Masks::Profile::SETTINGS

          params[:settings].each do |name, value|
            next unless names.include?(name)
            value = name.end_with?('.enabled') || name.end_with?('.signups') ? value.present? : value.presence
            keys = name.split('.')
            next if value == @profile.setting(*keys)

            last_key = keys.pop
            current = hash
            keys.each do |k|
              current[k] ||= {}
              current = current[k]
            end

            current[last_key] = value
          end

          hash
        end
      end
    end
  end
end
