# frozen_string_literal: true

module Masks
  module Access
    # Access class for +actor.scopes+
    #
    # This access class can add or remove scopes from an actor.
    class ActorScopes
      include Access

      access "actor.scopes"

      def assign_scopes(scopes)
        actor.assign_scopes!(*scopes)
      end
    end
  end
end
