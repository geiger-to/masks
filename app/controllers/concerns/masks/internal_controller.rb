module Masks
  module InternalController
    extend ActiveSupport::Concern

    private

    def masks_session
      request.env["masks.session"]
    end

    delegate :current_manager,
             :current_client,
             :current_device,
             to: :masks_session
  end
end
