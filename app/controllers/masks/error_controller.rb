# frozen_string_literal: true

module Masks
  # @visibility private
  class ErrorController < ApplicationController
    def render_unauthorized
      render plain: "", status: 401
    end

    def redirect
      redirect_to masked_session.mask.fail
    end
  end
end
