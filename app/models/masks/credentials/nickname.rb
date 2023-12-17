module Masks
  module Credentials
    class Nickname < Masks::Credential
      checks :actor

      delegate :actor_id, :nickname, to: :actor, allow_nil: true

      validates :nickname, :actor, presence: true
      validate :validates_custom, if: :nickname

      def lookup
        return if self.actor

        actor = (config.find_actor(session, nickname: nickname_param) if nickname_param)
        actor ||= (config.build_actor(session, nickname: nickname_param) if nickname_param)

        actor.nickname =
          prefix_nickname(actor.nickname, default: actor.nickname) if actor&.new_record?

        actor
      end

      def maskup
        approve! if valid?
      end

      private

      def nickname_param
        @nickname_param ||=
          prefix_nickname(session_params[:nickname], default: session_params[:nickname])
      end

      def validates_custom
        return unless nickname

        validates_length :nickname, nickname_config&.length

        return unless nickname_format

        errors.add(:nickname, :format) unless nickname_format.match?(nickname)
        debugger unless nickname_format.match?(nickname)
      end
    end
  end
end
