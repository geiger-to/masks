require "test_helper"

class BackupCodeTest < MasksTestCase
  include AuthHelper

  setup { client.add_check!("second-factor") }

  test "10 backup codes must be provided at setup-time" do
    log_in "manager"

    attempt event: "backup-codes:replace", updates: { codes: %w[test test] }

    assert_equal 2, auth_result[:warnings].length
    assert_predicate seeder.manager.reload.backup_codes, :blank?
    assert_not auth_result.dig(:actor, :savedBackupCodesAt)

    attempt event: "backup-codes:replace",
            updates: {
              codes: Array.new(10) { SecureRandom.uuid },
            }

    assert auth_result.dig(:actor, :savedBackupCodesAt)
    assert_predicate seeder.manager.reload.backup_codes, :present?
  end

  test "backup codes can be used in lieu of other 2fa options" do
    codes = Array.new(10) { SecureRandom.uuid }
    setup_totp "manager"
    seeder.manager.save_backup_codes(codes)
    log_in "manager"

    attempt event: "backup-code:verify", updates: { code: codes.first }

    assert_login
  end

  test "backup codes not in the actor's list are ignored" do
    setup_totp "manager"
    log_in "manager"

    attempt event: "backup-code:verify", updates: { code: "invalid-code" }

    refute_settled
  end

  test "backup codes must be replaced after using the last one" do
    codes = Array.new(10) { SecureRandom.uuid }
    setup_totp "manager"
    actor = seeder.manager.reload
    actor.save_backup_codes(codes)
    actor.update(backup_codes: [actor.backup_codes.first])

    log_in "manager"

    attempt event: "backup-code:verify", updates: { code: codes.first }

    refute_settled
    assert_prompt "second-factor"

    attempt event: "backup-codes:replace",
            updates: {
              codes: Array.new(10) { SecureRandom.uuid },
            }

    assert_login
  end
end
