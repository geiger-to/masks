require "test_helper"

class ActorMutationTest < GraphQLTestCase
  def query
    "
      mutation ($input: ActorInput!) {
        actor(input: $input) {
          actor {
            identifier
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

  test "managers can create actors" do
    log_in "manager"

    gql query, input: { identifier: "testing", signup: true }

    assert_equal "testing", gql_result("actor", "actor", "identifier")
    assert_predicate Masks.identify("testing"), :persisted?
  end

  test "actors are only created with the signup param" do
    log_in "manager"

    gql query, input: { identifier: "testing" }

    assert_predicate Masks.identify("testing"), :new_record?
  end

  test "invalid emails return an error" do
    log_in "manager"

    gql query, input: { identifier: "&&&&@%%", signup: true }

    assert_no_changes -> { Masks::Actor.count } do
      assert_includes gql_result("actor", "errors"), "Email is invalid"
    end
  end

  test "invalid nicknames return an error" do
    log_in "manager"

    gql query, input: { identifier: "&&&&", signup: true }

    assert_no_changes -> { Masks::Actor.count } do
      assert_includes gql_result("actor", "errors"), "Nickname is invalid"
    end
  end

  test "passwords can be changed for any existing actor" do
    log_in "manager"

    assert tester.authenticate("password")
    gql query, input: { id: tester.key, password: "testing123" }
    assert tester.reload.authenticate("testing123")
  end

  test "passwords can be reset for any existing actor" do
    log_in "manager"

    assert tester.authenticate("password")
    gql query, input: { id: tester.key, resetPassword: true }
    assert_nil tester.reload.password_digest
  end

  test "backup codes can be reset for any existing actor" do
    log_in "manager"

    tester.update_attribute!(:backup_codes, ["test"])
    assert tester.reload.backup_codes
    gql query, input: { id: tester.key, resetBackupCodes: true }
    assert_nil tester.reload.backup_codes
  end

  test "scopes can be changed for any existing actor" do
    log_in "manager"

    gql query,
        input: {
          id: tester.key,
          scopes: "foobar testing baz\nbaz testing2\nbaz",
        }
    assert_equal %w[foobar testing testing2 baz].sort, tester.reload.scopes_a
  end

  test "passwords and scopes cannot be set on signup" do
    log_in "manager"

    gql query,
        input: {
          identifier: "foobar",
          password: "testing123",
          scopes: "test",
          signup: true,
        }
    assert_nil Masks.identify("foobar").password_digest
    assert_empty Masks.identify("foobar").scopes
  end
end
