# frozen_string_literal: true

module Masks
  # @visibility private
  class ActorMailer < ApplicationMailer
    layout "masks/mailer"

    def verify_email
      @config = Masks.configuration
      @email = params[:email]

      mail(to: @email.email, subject: t(".subject"))
    end
  end
end
