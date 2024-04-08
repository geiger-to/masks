# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class BaseController < ApplicationController
      layout "masks/manage"

      class << self
        def section(name)
          before_action { @section = name }
        end
      end

      helper_method :current_actor, :section

      attr_accessor :section
    end
  end
end
