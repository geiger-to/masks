# frozen_string_literal: true

module Masks
  # @visibility private
  module Admin
    class DevicesController < BaseController
      section :devices

      before_action only: %i[show update] do
        @device = tenant.devices.find(params[:id])
        @actors = @device.actors.distinct
      end

      rescue_from Pagy::OverflowError do
        redirect_to admin_devices_path
      end

      def index
        scope = tenant.devices.includes(actors: [:identifiers])
        scope =
          if search_query && ValidatesHost::Ip.new(search_query).valid?
            scope.where(ip_address: search_query)
          elsif search_query
            scope.where(identifiers: { value: search_query })
          else
            scope.all
          end

        @pagy, @devices = pagy(scope.order(created_at: :desc))
      end

      def update
        return unless params[:expire_actor] || params[:expire_all]

        if params[:expire_actor]
          @device.expire!(actor: params[:expire_actor], client:)
        elsif params[:expire_all]
          @device.expire!(all: true, client:)
        end

        flash[:info] = "sessions expired"

        redirect_back fallback_location: admin_devices_path
      end

      def logout
        device = Masks::Device.find(params[:id])
        device.reset_version!

        redirect_back fallback_location: admin_devices_path
      end

      private

      def search_query
        params[:q].presence
      end
    end
  end
end
