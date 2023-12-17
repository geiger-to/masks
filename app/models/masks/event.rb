# frozen_string_literal: true

module Masks
  # Publishes events using +ActiveSupport::Notifications+
  class Event
    class << self
      def emit(name, **opts, &block)
        ActiveSupport::Notifications.instrument("masks.#{name}", **opts) do
          block.call
        end
      end
    end
  end
end
