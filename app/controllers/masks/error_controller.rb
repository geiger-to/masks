module Masks
  # @visibility private
  class ErrorController < ApplicationController
    def render_401
      render plain: "", status: 401
    end

    def render_400
      render plain: "", status: 401
    end

    def redirect
      redirect =
        if current_session.mask.fail
          current_session.mask.fail
        else
          current_session.config.redirect_url(current_session)
        end

      redirect_to redirect
    end
  end
end
