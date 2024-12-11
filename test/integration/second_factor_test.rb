require "test_helper"

class SecondFactorTest < MasksTestCase
  include AuthHelper

  setup { client.add_check!("second-factor") }

  test "actors must add a factor + backup codes when required" do
    log_in "manager"

    assert_prompt "second-factor"
    refute_settled

    travel_to Time.parse("2024-11-17T19:57:11+0000")

    attempt event: "backup-codes:replace",
            updates: {
              codes: Array.new(10) { SecureRandom.uuid },
            }
    refute_settled
    attempt event: "totp:verify",
            updates: {
              secret: "JBSWY3DPEHPK3PXP",
              code: "247086",
            }
    refute_settled
    attempt event: "second-factor:enable"
    assert_settled
  end
end
