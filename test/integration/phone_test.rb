require "test_helper"

class PhoneTest < MasksTestCase
  include AuthHelper
  include Masks::Integration

  NUMBER = "+12345678901"

  setup do
    client.add_check!("second-factor")
    manager.phones.create!(number: NUMBER)
    manager.save_backup_codes(Array.new(10) { SecureRandom.alphanumeric(10) })
    manager.enable_second_factor!
  end

  test "sms codes can be verified given a pre-registered number" do
    log_in "manager"

    attempt event: "phone:send", updates: { phone: NUMBER }
    attempt event: "phone:verify",
            updates: {
              phone: NUMBER,
              code: TestPhone.verifications[NUMBER],
            }

    assert_login
  end

  test "sms codes are useless when the feature is disabled" do
    Masks.installation.modify!(phones: { enabled: false })

    log_in "manager"

    attempt event: "phone:send", updates: { phone: NUMBER }
    attempt event: "phone:verify",
            updates: {
              phone: NUMBER,
              code: TestPhone.verifications[NUMBER],
            }

    assert_prompt "second-factor"
    refute_settled
  end

  test "invalid codes are useless" do
    log_in "manager"

    attempt event: "phone:send", updates: { phone: NUMBER }
    attempt event: "phone:verify", updates: { phone: NUMBER, code: "invalid" }

    assert_prompt "second-factor"
    assert_warning "invalid-code:invalid"
    refute_settled
  end

  test "twilio can be used for verification" do
    Masks.installation.modify!(
      integration: {
        phone: "twilio",
        twilio: {
          service_sid: "53rv1c3",
          account_sid: "123",
          auth_token: "xyz",
        },
      },
    )

    travel_to Time.parse("2024-12-03T18:51:10.017Z")
    freeze_time

    log_in "manager"

    VCR.use_cassette("twilio-send") do
      attempt event: "phone:send", updates: { phone: NUMBER }
    end

    VCR.use_cassette("twilio-verify") do
      attempt event: "phone:verify", updates: { phone: NUMBER, code: "288720" }
    end

    assert_login
  end
end
