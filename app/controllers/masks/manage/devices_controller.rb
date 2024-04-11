# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class DevicesController < BaseController
      section :devices

      rescue_from Pagy::OverflowError do
        redirect_to manage_devices_path
      end

      def index
        scope = Masks.configuration.model(:device).includes(:actor)
        scope =
          if search_query && ValidatesHost::Ip.new(search_query).valid?
            scope.where(ip_address: search_query)
          elsif search_query
            scope.where(actor: { nickname: search_query })
          else
            scope.all
          end

        @pagy, @devices = pagy(scope.order(created_at: :desc))
      end

      def logout
        device = Masks.configuration.model(:device).find(params[:id])
        device.reset_version!

        flash[:info] = "device logged out"

        redirect_back fallback_location: manage_devices_path
      end

      private

      def search_query
        params[:q].presence
      end
    end
  end
end
