# frozen_string_literal: true

module Masks
  module Credentials
    # Checks for an :actor given a matching identifier (nickname, email, phone, etc).
    class Signup < Masks::Credential
      checks :actor

      def lookup
        fail! if Masks.setting('signups.disabled')

        return if actor

        config
          .build_actor(session, nickname:, email:, phone:)
          .tap do |actor|
            actor.signup = true
          end
      end

      def maskup
        approve! if actor&.valid?
      end

      private

      def nickname
        @nickname ||= if accepted?('nickname')
          Masks.configuration.model(:nickname_id).new(value: session_params[:nickname])
        end
      end

      def email
        @email ||= if accepted?('email')
          Masks.configuration.model(:email_id).new(value: session_params[:email])
        end
      end

      def phone
        @phone ||= if accepted?('phone')
          Masks.configuration.model(:phone_id).new(value: session_params[:phone])
        end
      end

      def accepted?(name)
        Masks.setting("#{name}.allowed") && Masks.setting("#{name}.required")
      end

      def validates_params
        # actor.validate
        if accepted?('nickname') && !nickname.valid?
          errors.add(:base, nickname.errors.full_messages.first)
        end

        nil

        # if accepted?('email') && s
        #   errors.add(:email, :blank
        # end

        # return unless accepted?('phone') && session_params[:phone]&.blank?
        #   errors.add(:phone, :blank)

        # TODO: validate lengths and values
      end
    end
  end
end
