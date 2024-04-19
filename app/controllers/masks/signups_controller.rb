# frozen_string_literal: true

module Masks
  # @visibility private
  class SignupsController < ApplicationController
    before_action :require_signups
    before_action :redirect_if_logged_in, only: %i[new]

    helper_method :accepted?

    def create
      flash[
        :errors
      ] = masked_session.errors.full_messages

        if masked_session.passed?
          redirect_to(session.delete(:return_to) || masked_session.mask.pass ||
            Masks.configuration.site_links[:after_signup])
        else
          render 'new'
        end
    end

    private

    def accepted?(field)
      masks_settings["#{field}.allowed"] && masks_settings["#{field}.required"]
    end

    def require_signups
      render_not_found if masks_settings['signups.disabled']
    end

    def redirect_if_logged_in
      redirect_to '/' if current_actor
    end
  end
end
