require "test_helper"

class OtpSecretMutationTest < GraphQLTestCase
  def query
    "
      mutation ($input: OtpSecretInput!) {
        otpSecret(input: $input) {
          otpSecret {
            id
            createdAt
          }

          errors
        }
      }
    "
  end

  test "masks:manage is required" do
    log_in "manager"

    manager.scopes = ""
    manager.save!

    gql query, input: { identifier: "testing", signup: true }

    assert gql_errors
    assert_not gql_result
  end

  test "managers can delete otpSecrets" do
    log_in "manager"

    secret = tester.otp_secrets.create!(name: "test")

    gql query,
        input: {
          actorId: tester.key,
          id: secret.public_id,
          action: "delete",
        }

    assert_not Masks::OtpSecret.find_by(public_id: secret.public_id)
  end
end
