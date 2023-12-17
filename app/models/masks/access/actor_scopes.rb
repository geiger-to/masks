module Masks
  module Access
    class ActorScopes
      include Access

      access "actor.scopes"

      def assign_scopes(scopes)
        actor.assign_scopes!(*scopes)
      end
    end
  end
end
