require "test_helper"

class OtpCodeTest < MasksTestCase
  include AuthHelper

  setup do
    client.add_check!("second-factor")
    travel_to Time.parse("2024-11-17T19:57:11+0000")
  end

  test "otp codes must be valid to be added" do
    log_in "manager"

    attempt event: "otp:verify",
            updates: {
              secret: "JBSWY3DPEHPK3PXP",
              code: "247085",
            }
    assert manager.otp_secrets.count == 0
    assert_warning "invalid-code:247085"

    attempt event: "otp:verify",
            updates: {
              secret: "JBSWY3DPEHPK3PXP",
              code: "247086",
            }
    assert manager.otp_secrets.count == 1
  end

  test "saved secrets can be used after verification" do
    setup_otp("manager")

    log_in "manager"
    assert_prompt "second-factor"

    id = manager.otp_secrets.first.public_id

    travel_to Time.parse("2024-11-17T20:12:35+0000") do
      attempt event: "otp:verify", updates: { id:, code: "789355" }
      refute_settled
      attempt event: "otp:verify", updates: { id:, code: "789356" }
      assert_login
    end
  end

  test "new secrets cannot be added after setup" do
    setup_otp("manager")

    log_in "manager"
    assert_prompt "second-factor"

    travel_to Time.parse("2024-11-17T20:12:35+0000") do
      attempt event: "otp:verify",
              updates: {
                secret: "JBSWY3DPEHPK3PXP",
                code: "247086",
              }
      assert manager.otp_secrets.count == 1
      assert_warning "invalid-otp"
    end
  end

  test "saved secrets' names can be changed after setup" do
    log_in "manager"

    attempt event: "otp:verify",
            updates: {
              secret: "JBSWY3DPEHPK3PXP",
              code: "247086",
            }

    assert secret = manager.otp_secrets.first

    attempt event: "otp:name",
            updates: {
              id: secret.public_id,
              name: "testing",
            }

    assert_equal "testing", secret.reload.name
  end

  private

  def setup_otp(*args)
    log_in *args

    attempt event: "otp:verify",
            updates: {
              secret: "JBSWY3DPEHPK3PXP",
              code: "247086",
            }
    attempt event: "backup-codes:replace",
            updates: {
              codes: Array.new(10) { SecureRandom.uuid },
            }
    attempt event: "second-factor:enable"

    integration_session.reset!
  end
end
