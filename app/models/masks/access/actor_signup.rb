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
        actor = session.mask.actor_scope.new(session:, signup: true)
        actor.identifiers = opts.map do |key, value|
          config.identifier(key:, value:)
        end.compact

        actor.password = opts[:password]
        actor.save if actor.valid?
        actor
      end
    end
  end
end
