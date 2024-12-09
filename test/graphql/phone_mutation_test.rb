require "test_helper"

class PhoneMutationTest < GraphQLTestCase
  def query
    "
      mutation ($input: PhoneInput!) {
        phone(input: $input) {
          phone {
            number
            createdAt
            verifiedAt
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

  test "managers can create phones" do
    number = "12345678901"

    log_in "manager"

    gql query, input: { actorId: tester.key, number:, action: "create" }

    assert Masks::Phone.find_by(number: "+#{number}")
  end

  test "managers cannot create invalid phones" do
    number = "invalid"

    log_in "manager"

    gql query, input: { actorId: tester.key, number:, action: "create" }

    assert_includes gql_result("phone", "errors"), "Phone number is invalid"
  end

  test "managers can delete phones" do
    number = "+12345678901"

    log_in "manager"

    gql query, input: { actorId: tester.key, number:, action: "create" }
    assert Masks::Phone.find_by(number:)
    gql query, input: { actorId: tester.key, number:, action: "delete" }
    assert_not Masks::Phone.find_by(number:)
  end
end
