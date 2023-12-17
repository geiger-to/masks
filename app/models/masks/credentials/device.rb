module Masks
  module Credentials
    # Checks for a known, valid :device.
    #
    # If the device is not associated with the session's actor, it will be.
    # Identification is based on the +user_agent+ and a few other facets.
    class Device < Masks::Credential
      checks :device

      def lookup
        return unless actor

        device = config.find_device(session, actor: actor)

        session.extras(device: device)

        nil
      end

      def maskup
        device = session.extra(:device)

        return deny! unless device

        session_key = session.data[:device_key]

        # ensure devices match across sessions, which would only happen if a
        # session cookie happened is shared across machines. this destroys
        # the entire session and cleans up everything involved.
        if session_key && device.session_key != session_key
          raise "invalid device"
        end

        # store devices that are found in a database of known devices
        if device.known?
          session.data[:device_key] = device.session_key
          actor.devices << device
          approve!
        else
          cleanup
          deny!
        end
      end

      def backup
        session.extra(:device)&.touch(:accessed_at) if session&.passed?
      end

      def cleanup
        device = session.extra(:device)
        device.reset_version if device

        session.data[:device_key] = nil
      end
    end
  end
end
