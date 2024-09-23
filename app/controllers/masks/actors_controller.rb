# frozen_string_literal: true

module Masks
  # @visibility private
  class ActorsController < ApplicationController
    def current
      respond_to do |format|
        format.json { render json: ActorResource.new(current_actor) }
        format.html { render(:current) }
      end
    end
  end
end
