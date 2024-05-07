# frozen_string_literal: true

module Masks
  # @visibility private
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "mailer"

    helper do
      def logged_in?
        false
      end

      def masks_settings
        Masks.settings
      end

      def dark_mode_allowed?
        false
      end
    end
  end
end
