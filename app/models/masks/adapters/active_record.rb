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

      def find_actor(session, identifier:, **opts)
        session
          .mask
          .actor_scope
          .includes(:identifiers)
          .find_by(identifiers: { value: identifier.value, type: identifier.type })
      end

      def find_actors(session, ids)
        session.mask.actor_scope.where(uuid: ids).to_a
      end

      def build_actor(session, nickname: nil, email: nil, phone: nil, **opts)
        record = session.mask.actor_scope.new(session:)
        record.identifiers << nickname if nickname
        record.identifiers << email if email
        record.identifiers << phone if phone
        record
      end

      def expire_actors
        @config.model(:actor).expired.destroy_all
      end

      def expire_recoveries
        @config.model(:recovery).expired.destroy_all
      end

      def find_recovery(_session, **opts)
        if opts[:token]
          @config.model(:recovery).recent.find_by(token: opts[:token])
        elsif opts[:id]
          @config.model(:recovery).recent.find_by(id: opts[:id])
        end
      end

      def build_recovery(session, **opts)
        @config.model(:recovery).new(configuration: @config, session:, **opts)
      end
    end
  end
end
