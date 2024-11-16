module Masks
  module Prompts
    class BackupCode < SecondFactor
      checks "second-factor"

      event "backup-codes:replace" do
        next unless actor

        unless actor.save_backup_codes(updates["codes"])
          actor.errors.full_messages.each { |error| warn! error }
        end
      end

      event "backup-code:verify" do
        code = updates["code"]

        next unless actor && code

        if actor.verify_backup_code(code)
          checked! "second-factor", with: :backup_code
        else
          warn! "invalid-code", code
        end
      end
    end
  end
end
