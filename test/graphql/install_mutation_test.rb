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
              phones
              webauthn
              backupCodes
              checks
              clients
              integration
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

  test "integration settings can be modified" do
    log_in "manager"

    gql query,
        input: {
          integration: {
            smtp: {
              address: "example.com",
              userName: "test",
              password: "test",
            },
          },
        }

    assert_equal "example.com", Masks.setting(:integration, :smtp, :address)
    assert_equal "test", Masks.setting(:integration, :smtp, :user_name)
    assert_equal "test", Masks.setting(:integration, :smtp, :password)
  end
end
