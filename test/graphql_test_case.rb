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
end
