# frozen_string_literal: true

module Masks
  module Credentials
    # Checks :password for a match.
    class Password < Masks::Credential
      checks :password

      def lookup
        actor.password = password if actor&.new_record? && password

        nil
      end

      def maskup
        return unless password

        actor&.authenticate(password) && actor&.valid? ? approve! : deny!
      end

      private

      def password
        session_params[:password]
      end
    end
  end
end
