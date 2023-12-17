module Masks
  module Credentials
    class Session < Masks::Credential
      checks :actor

      def lookup
        actor_ids = session.past_checks.keys
        actor_id = session.data[:actor_id]
        actors =
          if actor_ids.any?
            actors = config.find_actors(session, actor_ids)
          else
            []
          end

        # only lookup and return the current actor if
        # it's not provided via a param (e.g. someone
        # is trying to login)
        actor =
          (actors.find { |a| a.actor_id == actor_id } if actor_id && !session_params[:actor_id])

        session.alternates(*actors)

        if optional? && !actors.present?
          # let them in anyway
          actor = Actors::Anonymous.new(session: session)
        end

        actor
      end

      def maskup
        return unless session.data[:actor_id] || optional?

        approve! if session.data[:actor_id] == actor&.actor_id || optional?
      end

      def backup
        session.data[:actor_id] = actor.actor_id if actor && passed?
      end

      def cleanup
        session.data[:actor_id] = nil
      end
    end
  end
end
