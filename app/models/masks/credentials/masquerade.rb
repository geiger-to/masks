module Masks
  module Credentials
    class Masquerade < Masks::Credential
      checks :actor

      def lookup
        return if session.actor

        value = session.data[:as]

        @loaded =
          case value
          when Masks::ANON
            if session.mask&.allow_anonymous?
              Actors::Anonymous.new(session: session)
            end
          when session.mask.actor_scope
            value
          when ValidateEmail.valid?(value)
            config.find_actor(session, email: value)
          when String
            config.find_actor(session, nickname: prefix_nickname(value))
          end
      end

      def maskup
        approve! if @loaded
      end
    end
  end
end
