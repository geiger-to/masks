class GraphQLTestCase < MasksTestCase
  include AuthHelper

  def gql(query, **vars)
    post "/graphql", as: :json, params: { query:, variables: vars }
  end

  def gql_result(*keys)
    response.parsed_body.dig(*["data", *keys])
  end

  def gql_errors
    response.parsed_body.dig("errors")
  end

  def self.managers_only(name, query, **vars, &block)
    setup { log_in "manager" }

    test "masks:manage is required for #{name}" do
      t = self

      vars = t.instance_exec(&block) if block_given?

      gql query, **vars

      assert_nil gql_errors

      manager.scopes = ""
      manager.save!

      gql query, **vars

      assert gql_errors
      assert_not gql_result
    end
  end

  def self.paginated(key, query, &block)
    test "#{key} can be paginated" do
      (MasksSchema::PAGE_SIZE + 1).times { instance_exec(&block) }

      gql query

      assert gql_result.dig(key, "pageInfo", "hasNextPage")
      assert_equal MasksSchema::PAGE_SIZE, gql_result.dig(key, "nodes").length
    end
  end
end
