module Masks
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
