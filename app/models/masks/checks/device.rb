module Masks
  module Checks
    class Device < Base
      def checked!(device:, **args)
        state.rails_session["device"] ||= {
          "id" => device&.public_id,
          "version" => device&.version,
          "checked" => true,
        }
      end

      def persist!(device)
        return unless checked?

        if device.new_record? || device.updated_at < 1.minute.ago
          device.updated_at = Time.current
          device.save
        end
      end

      def checked?
        state.rails_session.dig("device", "checked")
      end

      def device_id
        state.rails_session.dig("device", "id")
      end

      def device_version
        state.rails_session.dig("device", "version")
      end

      def reset!
        state.rails_session.delete("device")
      end
    end
  end
end
