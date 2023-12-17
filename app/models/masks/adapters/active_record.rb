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

      def find_key(session, secret:)
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

        record =
          Masks::Rails::Device.find_or_initialize_by(actor: actor, key: key)
        record.session = session
        record
      end

      def find_actor(session, **opts)
        if opts[:email]
          session
            .mask
            .actor_scope
            .includes(:emails)
            .find_by(emails: { email: opts[:email]&.downcase, verified: true })
        elsif opts[:nickname]
          session.mask.actor_scope.find_by(nickname: opts[:nickname])
        end
      end

      def find_actors(session, ids)
        session.mask.actor_scope.where(nickname: ids).to_a
      end

      def build_actor(session, **opts)
        opts[:session] = session
        record =
          session.mask.actor_scope.new(
            session: session,
            nickname: opts[:nickname]
          )
        record.emails.build(email: opts[:email]) if opts[:email]
        record
      end

      def expire_actors
        @config.model(:actor).expired.destroy_all
      end

      def expire_recoveries
        @config.model(:recovery).expired.destroy_all
      end

      def find_recovery(session, **opts)
        if opts[:token]
          @config.model(:recovery).recent.find_by(token: opts[:token])
        elsif opts[:id]
          @config.model(:recovery).recent.find_by(id: opts[:id])
        end
      end

      def build_recovery(session, **opts)
        @config.model(:recovery).new(
          configuration: @config,
          session: session,
          **opts
        )
      end
    end
  end
end
