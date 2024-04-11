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
        @pagy, @devices =
          pagy(Masks.configuration.model(:device).all.order(created_at: :desc))
      end
    end
  end
end
