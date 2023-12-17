# frozen_string_literal: true

module Masks
  module Credentials
    # Checks :factor2 for a valid backup code.
    class BackupCode < Masks::Credential
      include Factor2

      private

      def param
        :backup_code
      end

      def secret
        actor&.backup_codes if actor&.saved_backup_codes?
      end

      def verify(code)
        code if secret&.fetch(code, false)
      end

      def backup
        return unless verified?

        actor.update_attribute("backup_codes", secret.merge(code => false))
      end
    end
  end
end
