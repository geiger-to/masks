# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class ActorsController < BaseController
      def index
        @pagy, @actors = pagy(Masks::Rails::Actor.all)
      end
    end
  end
end
