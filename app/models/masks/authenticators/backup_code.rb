module Masks
  module Authenticators
    class BackupCode < Base
      event "backup-codes:add" do
        next unless actor

        warn! "invalid-codes" unless actor.save_backup_codes(updates["codes"])
      end
    end
  end
end
