module Masks
  module Authenticators
    class BackupCode < Base
      event "backup-codes:replace" do
        next unless actor

        if actor.save_backup_codes(updates["codes"])
          second_factor! :backup_code
        else
          warn! "invalid-codes"
        end
      end

      event "backup-code:verify" do
        code = updates["code"]

        next unless actor && code

        if actor.verify_backup_code(code)
          second_factor! :backup_code
        else
          warn! "invalid-code", code
        end
      end
    end
  end
end
