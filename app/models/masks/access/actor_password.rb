module Masks
  module Access
    class ActorPassword
      include Access

      access "actor.password"

      def change_password(password)
        actor.changed_password_at = Time.current
        actor.password = password
        actor.save if actor.valid?
      end
    end
  end
end
