# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class ClientsController < BaseController
      section :clients

      def index
        @pagy, @clients = pagy(Masks::Rails::OpenID::Client.all)
      end
    end
  end
end
