# frozen_string_literal: true

module Masks
  module Credentials
    # Checks for an :actor given a matching nickname.
    class Nickname < Masks::Credential
      checks :actor

      delegate :actor_id, :nickname, to: :actor, allow_nil: true

      validates :nickname, :actor, presence: true
      validate :validates_custom, if: :nickname

      def lookup
        return if actor

        actor =
          (
            if nickname_param
              config.find_actor(session, nickname: nickname_param)
            end
          )
        actor ||=
          if nickname_param
            config
              .build_actor(session, nickname: nickname_param)
              .tap { |actor| actor.signup = true }
          end

        if actor&.new_record?
          actor.nickname =
            prefix_nickname(actor.nickname, default: actor.nickname)
        end

        actor
      end

      def maskup
        approve! if valid?
      end

      private

      def nickname_param
        @nickname_param ||=
          prefix_nickname(
            session_params[:nickname],
            default: session_params[:nickname]
          )
      end

      def validates_custom
        return unless nickname

        validates_length :nickname, nickname_config&.length

        return unless nickname_format

        errors.add(:nickname, :format) unless nickname_format.match?(nickname)
      end
    end
  end
end
