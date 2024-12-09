require "test_helper"

class EmailMutationTest < GraphQLTestCase
  def query
    "
      mutation ($input: EmailInput!) {
        email(input: $input) {
          email {
            address
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

  test "managers can create emails" do
    address = "test2@example.com"

    log_in "manager"

    gql query, input: { actorId: tester.key, address:, action: "create" }

    assert_equal address, gql_result("email", "email", "address")
    assert Masks::Email.for_login.find_by(address:)
  end

  test "managers cannot create invalid emails" do
    address = "invalid"

    log_in "manager"

    gql query, input: { actorId: tester.key, address:, action: "create" }

    assert_includes gql_result("email", "errors"), "Email address is invalid"
  end

  test "managers can delete emails" do
    address = "test2@example.com"

    log_in "manager"

    gql query, input: { actorId: tester.key, address:, action: "create" }
    assert Masks::Email.for_login.find_by(address:)
    gql query, input: { actorId: tester.key, address:, action: "delete" }
    assert_not Masks::Email.for_login.find_by(address:)
  end

  test "managers cannot delete emails used as identifiers" do
    address = "test@example.com"

    log_in "manager"

    tester.update_attribute(:nickname, nil)
    assert_equal address, tester.reload.identifier

    gql query, input: { actorId: tester.key, address:, action: "delete" }

    assert_includes gql_result("email", "errors"), "Cannot remove primary email"
  end

  test "managers can verify emails" do
    address = "test2@example.com"

    log_in "manager"

    gql query, input: { actorId: tester.key, address:, action: "create" }
    assert_not_predicate Masks::Email.for_login.find_by(address:), :verified?
    gql query, input: { actorId: tester.key, address:, action: "verify" }
    assert_predicate Masks::Email.for_login.find_by(address:), :verified?
  end

  test "managers can unverify emails" do
    address = "test2@example.com"

    log_in "manager"

    gql query, input: { actorId: tester.key, address:, action: "create" }
    gql query, input: { actorId: tester.key, address:, action: "verify" }
    assert_predicate Masks::Email.for_login.find_by(address:), :verified?
    gql query, input: { actorId: tester.key, address:, action: "unverify" }
    assert_not_predicate Masks::Email.for_login.find_by(address:), :verified?
  end
end
