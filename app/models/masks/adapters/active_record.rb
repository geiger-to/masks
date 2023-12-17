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

      def redirect_url(session)
        return "/"
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

      def find_recovery(session, **opts)
        if opts[:token]
          @config.model(:recovery).find_by(token: opts[:token])
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
