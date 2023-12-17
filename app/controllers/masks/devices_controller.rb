# frozen_string_literal: true

module Masks
  # @visibility private
  class DevicesController < ApplicationController
    require_mask type: :session, only: :update

    def update
      device =
        masked_session.config.find_device(masked_session, key: params[:key])

      if device&.persisted? && params[:reset]
        device.reset_version
        device.save!
      end

      redirect_back_or_to "/"
    end
  end
end
