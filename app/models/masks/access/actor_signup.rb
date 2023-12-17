module Masks
  module Access
    class ActorSignup
      include Access

      access "actor.signup"

      def signup(**opts)
        actor =
          (configuration.build_actor(session, **opts.slice(:nickname, :email)))
        actor.password = opts[:password]
        actor.save if actor.valid?
        actor
      end
    end
  end
end
