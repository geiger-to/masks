module Masks
  module Credentials
    # As of now, simply keeps track of +last_login+ times on the actor.
    class LastLogin < Masks::Credential
      def backup
        actor&.touch(:last_login_at) if session && session.passed?
      end
    end
  end
end
