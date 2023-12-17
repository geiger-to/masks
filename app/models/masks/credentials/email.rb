# frozen_string_literal: true

module Masks
  module Credentials
    # Checks for an :actor given a matching email.
    class Email < Masks::Credential
      checks :actor

      def lookup
        return if actor || !email

        actor = config.find_actor(session, email:)
        actor ||=
          config.build_actor(
            session,
            email:,
            nickname: generate_nickname(email)
          )
        actor.signup = true
        actor
      end

      def maskup
        approve! if actor && email && valid?
      end

      private

      def email
        @email ||=
          [session_params[:email], session_params[:nickname]].find do |param|
            ValidateEmail.valid?(param)
          end
      end

      def generate_nickname(email)
        return email if !nickname_format || nickname_format.match?(email)

        parts = email.split("@")
        name = parts[0].gsub(/[^\w\d]/, "")

        prefix_nickname(
          "#{name.downcase.slice(0, 16)}#{SecureRandom.hex.slice(0, 8)}"
        )
      end
    end
  end
end
