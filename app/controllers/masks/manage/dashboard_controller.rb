# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class DashboardController < BaseController
      section :dashboard

      def index
        @clients = Masks.configuration.model(:openid_client).count
        @actors = Masks.configuration.model(:actor).count
      end
    end
  end
end
