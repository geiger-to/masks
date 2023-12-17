module Masks
  module Credentials
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
        actor.update_attribute("backup_codes", secret.merge(code => false)) if verified?
      end
    end
  end
end
