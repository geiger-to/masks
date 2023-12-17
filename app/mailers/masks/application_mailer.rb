module Masks
  # @visibility private
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "mailer"

    helper do
      def logged_in?
        false
      end
    end
  end
end
