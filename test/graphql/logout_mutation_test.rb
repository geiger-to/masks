require "test_helper"

class LogoutMutationTest < GraphQLTestCase
  QUERY =
    "
      mutation ($input: LogoutInput!) {
        logout(input: $input) {
          total
          errors
        }
      }
    "

  managers_only "logout", QUERY, input: { actor: "manager" }

  test "managers can log out all devices for an actor" do
    unowned = nil
    open_session do |sess|
      sess.extend AuthHelper
      sess.get "/manage"
      unowned = Masks::Device.last
    end

    open_session do |sess|
      sess.extend AuthHelper
      sess.get "/manage"
      sess.log_in "manager"
      sess.assert_logged_in :get, "/manage"

      assert_equal [0, 0], manager.reload.devices.map(&:version)

      gql QUERY, input: { actor: "manager" }

      assert_equal [1, 1], manager.reload.devices.map(&:version)
      assert_equal 0, unowned.reload.version
      assert_equal 2, gql_result.dig("logout", "total")

      sess.refute_logged_in :get, "/manage"
      refute_logged_in :get, "/manage"
    end
  end

  test "managers can log out idividual devices" do
    device = Masks::Device.first

    open_session do |sess|
      sess.extend AuthHelper
      sess.get "/manage"
      sess.log_in "manager"
      sess.assert_logged_in :get, "/manage"

      gql QUERY, input: { device: device.public_id }

      assert_equal [1, 0], manager.reload.devices.map(&:version)
      assert_equal 1, gql_result.dig("logout", "total")

      sess.assert_logged_in :get, "/manage"
      refute_logged_in :get, "/manage"
    end
  end
end
