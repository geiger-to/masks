# frozen_string_literal: true

module Masks
  module Credentials
    # Checks for a :recovery on the session.
    class Recovery < Masks::Credential
      checks :recovery

      def lookup
        return if actor

        @recovery =
          if recovery_key
            config.find_recovery(session, token: recovery_key)
          else
            config.build_recovery(
              session,
              nickname: nickname_param,
              email: email_param,
              phone: phone_param,
              value: recovery_value
            )
          end

        session.extras(recovery: @recovery)

        @recovery&.actor
      end

      def maskup
        return unless valid? && actor

        if recovery_key
          if recovery_password && @recovery&.valid?
            @recovery.reset_password!(recovery_password)
            approve!
          end
        elsif recovery_value && @recovery&.valid?
          @recovery.notify!
        end
      end

      private

      def recovery_value
        params.dig(:recover, :value) if writable?
      end

      def recovery_key
        params[:token]
      end

      def recovery_password
        params.dig(:recover, :password) if writable?
      end

      def phone_param
        @phone_param ||= Phonelib.valid?(recovery_value) ? recovery_value : nil
      end

      def email_param
        @email_param ||=
          ValidateEmail.valid?(recovery_value) ? recovery_value : nil
      end

      def nickname_param
        @nickname_param ||= prefix_nickname(recovery_value, default: nil)
      end
    end
  end
end
