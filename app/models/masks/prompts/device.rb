module Masks
  module Prompts
    class Device < Base
      COOKIE = :device

      checks "device"

      attr_accessor :device

      around_session do |auth, block|
        self.device = verify_device

        block.call

        check.persist!(device) unless auth.error
      end

      private

      def load_device
        Masks::Device.create_with(
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          version: check.device_version,
        ).find_or_initialize_by(public_id:)
      end

      def verify_device
        device = load_device
        device.check = check
        device.request = request

        if device.blocked?
          warn! "blocked-device", prompt: "device"
        elsif !device.valid?
          warn! "invalid-device", prompt: "device"
        elsif !device.valid?(:session)
          reset_session!
          reset_cookie!

          auth.extras device_errors: device.errors.full_messages.to_a

          warn! "invalid-device", prompt: "device"
        elsif checking?("device")
          check.checked!(device:)
        end

        device
      end

      def reset_session!
        state.reset!
        check.reset!
      end

      def reset_cookie!(value = nil)
        value ||= SecureRandom.alphanumeric(255)
        request.cookie_jar.signed[COOKIE] = {
          value:,
          expires: Masks::Device.cleanup_at,
        }
        value
      end

      def cookie_id
        request.cookie_jar.signed[COOKIE]&.presence
      end

      def public_id
        @public_id ||=
          if !cookie_id
            reset_session!
            reset_cookie!
          else
            cookie_id
          end
      end
    end
  end
end
