module Masks
  module Credentials
    # Checks for past :actor(s) on a session.
    #
    # This can be used in lieu of supplying identifying details like an
    # email/nickname (usually provided they were supplied in the past).
    class Session < Masks::Credential
      checks :actor

      def lookup
        return if session_params[:actor_id]

        actor_ids = session.data[:actors]&.keys || []
        actor_id = session.data[:actor]
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
          if actor_id
            actors.find do |a|
              a.actor_id == actor_id &&
                a.session_key == session.data[:actors][a.actor_id]
            end
          end

        if optional? && !actors.present?
          actor = Actors::Anonymous.new(session: session)
        end

        actor
      end

      def maskup
        return approve! if optional? && actor&.anonymous?

        actor_id = actor&.actor_id

        return unless actor_id && session.data[:actors]&.fetch(actor_id, nil)
        return unless session.data[:actor] == actor_id

        if session.data.dig(:actors, actor_id) == actor.session_key
          approve!
        else
          cleanup
        end
      end

      def backup
        return unless actor && passed?

        session.data[:actors] ||= {}
        session.data[:actors][actor.actor_id] = actor.session_key
        session.data[:actor] = actor.actor_id
      end

      def cleanup
        actor_id = actor&.actor_id || session.data[:actor]

        session.data[:actor] = nil
        session.data[:actors] ||= {}
        session.data[:actors].delete(actor_id)
      end
    end
  end
end
