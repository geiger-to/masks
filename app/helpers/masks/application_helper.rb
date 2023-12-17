module Masks
  # @visibility private
  module ApplicationHelper
    def totp_svg(uri, **opts)
      qrcode = RQRCode::QRCode.new(uri)
      raw qrcode.as_svg(**opts)
    end

    def factor2_required?
      checks = @session.checks_for(:session)

      return unless checks

      checks[:factor2] && !checks[:factor2]&.passed? && checks[:actor]&.passed? &&
        checks[:password]&.passed?
    end
  end
end
