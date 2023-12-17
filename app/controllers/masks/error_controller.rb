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
      redirect_to masked_session.mask.fail
    end
  end
end
