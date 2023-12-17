# frozen_string_literal: true

module Masks
  module Access
    # Access class for +actor.password+
    #
    # This access class can change that actor's password.
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
