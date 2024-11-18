module Masks
  module Prompts
    class Device < Base
      checks "device"

      around_session do |auth, block|
        self.device = identify_device

        block.call

        check.persist!(device) unless auth.error
      end

      private

      def identify_device
        device =
          Masks::Device.create_with(
            user_agent: request.user_agent,
            ip_address: request.remote_ip,
          ).find_or_initialize_by(public_id: check.device_id)

        if device.blocked?
          warn! "blocked-device", prompt: "device"
        elsif !device.valid?
          warn! "invalid-device", prompt: "device"
        elsif checking?("device")
          check.checked!(device:)
        end

        device
      end
    end
  end
end
