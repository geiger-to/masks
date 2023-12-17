# frozen_string_literal: true

module Masks
  # @visibility private
  module ApplicationHelper
    include Pagy::Frontend

    def totp_svg(uri, **opts)
      qrcode = RQRCode::QRCode.new(uri)
      raw qrcode.as_svg(**opts)
    end

    def device_icon(device)
      case device.device_type
      when "desktop"
        "computer"
      when "smartphone", "feature phone"
        "smartphone"
      when "tablet", "phablet", "portable media player"
        "tablet"
      when "console"
        "gamepad"
      when "tv", "smart display"
        "tv-2"
      when "car browser"
        "car"
      when "camera"
        "camera"
      when "smart speaker", "wearable", "peripheral"
        "bluetooth"
      else
        "question-circle"
      end
    end

    def logged_in?
      @session&.passed? && @session&.actor && !@session.actor.anonymous?
    end

    def factor2_required?
      checks = @session.checks_for(:session)

      return false unless checks

      checks[:factor2] && !checks[:factor2]&.passed? &&
        checks[:actor]&.passed? && checks[:password]&.passed?
    end
  end
end
