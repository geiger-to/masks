# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class BaseController < ApplicationController
      layout "masks/manage"

      class << self
        def section(section, subsection = nil)
          before_action do
            @section = [section, subsection].compact.join('-')
          end
        end
      end

      helper_method :current_actor, :section

      attr_accessor :section

      private

      def version
        Masks::VERSION
      end

      def render_not_found
        render 'masks/manage/404', status: :not_found
      end
    end
  end
end
