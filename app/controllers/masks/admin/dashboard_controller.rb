# frozen_string_literal: true

module Masks
  # @visibility private
  module Admin
    class DashboardController < BaseController
      section :dashboard

      def index
        @clients = tenant.clients.count
        @actors = tenant.actors.count
        @devices = tenant.devices.count
        @tokens = tenant.access_tokens.valid.count
      end
    end
  end
end
