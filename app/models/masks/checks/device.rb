module Masks
  module Checks
    class Device < Base
      def checked!(device:, **args)
        state.rails_session[:device] = { id: device&.public_id, checked: true }
      end

      def persist!(device)
        state.rails_session[:device] ||= { id: device.public_id }

        device.save if checked?
      end

      def checked?
        state.rails_session.dig(:device, :checked)
      end

      def device_id
        @device_id ||=
          state.rails_session.dig(:device, :id) || SecureRandom.uuid
      end
    end
  end
end
