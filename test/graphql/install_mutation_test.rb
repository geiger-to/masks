require "test_helper"

class InstallMutationTest < GraphQLTestCase
  def query
    "
        mutation ($input: InstallationInput!) {
          install(input: $input) {
            install {
              name
              url
              timezone
              region
              theme
              emails
              faviconUrl
              lightLogoUrl
              darkLogoUrl
              nicknames
              passwords
              passkeys
              loginLinks
              totpCodes
              smsCodes
              webauthn
              backupCodes
              checks
              clients
              createdAt
              updatedAt
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

    gql query, input: {}

    assert gql_errors
    assert_not gql_result
  end

  test "current installation is returned" do
    log_in "manager"

    gql query, input: {}

    assert_equal Masks.url, gql_result("install", "install", "url")
  end
end
