require "test_helper"

class QueryEntryTest < GraphQLTestCase
  QUERY_ENTRIES =
    "
      query ($client: String, $actor: String, $device: String) {
        entries(client: $client, actor: $actor, device: $device) {
          pageInfo {
            hasNextPage
            hasPreviousPage
            startCursor
            endCursor
          }
          nodes {
            id
          }
        }
      }
    "

  managers_only("entries", QUERY_ENTRIES)

  def make_entry
    Masks::Entry.create!(
      actor: make_actor,
      device: make_device,
      client: make_client,
    )
  end

  paginated "entries", QUERY_ENTRIES do
    make_entry
  end

  test "entries can be filtered by actor (via entries)" do
    3.times { make_entry }

    gql QUERY_ENTRIES, actor: "manager"

    assert_equal 1, gql_result.dig("entries", "nodes").length
  end

  test "entries can be filtered by client (via entries)" do
    3.times { make_entry }

    gql QUERY_ENTRIES, client: "manage"

    assert_equal 1, gql_result.dig("entries", "nodes").length
  end

  test "entries can be filtered by device (via entries)" do
    3.times { make_entry }

    gql QUERY_ENTRIES, device: Masks::Device.first.public_id

    assert_equal 1, gql_result.dig("entries", "nodes").length
  end
end
