# frozen_string_literal: true

module Masks
  module Adapters
    # ActiveRecord adapter for masks.
    #
    # Although this is designed for masks built-in models, any models
    # adhering to the same interface can be used. It is also possible to
    # override and extend the models used in the configuration.
    #
    # @see Masks::Adapter
    class ActiveRecord
      include Masks::Adapter

      def find_key(_session, secret:)
        Masks::Rails::Key.find_by(sha: Masks::Rails::Key.sha(secret))
      end

      def find_device(session, actor: nil, key: nil)
        device = session.device
        actor ||= session.actor

        return unless device.known? && actor

        key ||=
          Digest::SHA512.hexdigest(
            [
              device.name,
              device.os_name,
              device.device_name,
              device.device_type
            ].compact.join("-")
          )

        record = Masks::Rails::Device.find_or_initialize_by(actor:, key:)
        record.session = session
        record
      end

      def expire_actors
        @config.model(:actor).expired.destroy_all
      end
    end
  end
end
