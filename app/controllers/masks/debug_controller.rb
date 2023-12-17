# frozen_string_literal: true

module Masks
  class DebugController < ApplicationController
    def show
      render json: { session: session.to_h }
    end
  end
end
