
module Masks
  # @visibility private
  class ActorsController < ApplicationController
    require_mask with: :session, only: :current
  end
end
