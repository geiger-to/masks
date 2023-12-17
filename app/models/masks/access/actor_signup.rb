# frozen_string_literal: true

module Masks
  module Access
    # Access class for +actor.signup+.
    #
    # This access class creates a new actor.
    class ActorSignup
      include Access

      access "actor.signup"

      def signup(**opts)
        actor =
          configuration.build_actor(session, **opts.slice(:nickname, :email))
        actor.password = opts[:password]
        actor.save if actor.valid?
        actor
      end
    end
  end
end
