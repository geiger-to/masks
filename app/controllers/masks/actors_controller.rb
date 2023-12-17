module Masks
  # @visibility private
  class ActorsController < ApplicationController
    require_mask type: %i[session api], only: :current

    def current
      respond_to do |format|
        format.json { render json: ActorResource.new(current_actor) }
        format.html { render(:current) }
      end
    end
  end
end
