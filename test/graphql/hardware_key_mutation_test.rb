require "test_helper"

class HardwareKeyMutationTest < GraphQLTestCase
  def query
    "
      mutation ($input: HardwareKeyInput!) {
        hardwareKey(input: $input) {
          hardwareKey {
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

  test "managers can delete hardwareKeys" do
    log_in "manager"

    key =
      tester.hardware_keys.build(
        name: "test",
        public_key: "---",
        external_id: "123",
      )

    key.save!

    gql query,
        input: {
          actorId: tester.key,
          id: key.external_id,
          action: "delete",
        }

    assert_not Masks::HardwareKey.find_by(external_id: key.external_id)
  end
end
