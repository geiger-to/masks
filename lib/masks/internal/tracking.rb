module Masks
  module Internal
    class Tracking
      COOKIE = "masks_device"

      class << self
        def device(session)
          device = new(session).record

          session.bag :devices, current: device

          device
        end
      end

      def initialize(session)
        @session = session
      end

      def record
        @record ||=
          Masks::Device.create_with(
            user_agent: request.user_agent,
            ip_address: request.remote_ip,
          ).find_or_initialize_by(public_id:)
      end

      private

      def request
        @session.rails_request
      end

      def session
        @session.rails_session
      end

      def reset_id!
        value ||= SecureRandom.alphanumeric(255)

        request.cookie_jar.signed[COOKIE] = {
          value:,
          expires: Masks::Device.cleanup_at,
        }

        session["device_id"] = value

        value
      end

      def public_id
        @public_id ||=
          if session["device_id"]
            session["device_id"]
          elsif cookie_id
            cookie_id
          else
            reset_id!
          end
      end

      def cookie_id
        request.cookie_jar.signed[COOKIE]&.presence
      end
    end
  end
end
