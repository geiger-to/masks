module Masks
  module Credentials
    class LastLogin < Masks::Credential
      def backup
        actor&.touch(:last_login_at) if session && session.passed?
      end
    end
  end
end
