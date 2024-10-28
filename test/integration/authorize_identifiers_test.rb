class AuthorizeIdentifiersTest < MasksTestCase
  include AuthorizeHelper

  PREFIX = %i[data authorize]

  def client_id
    Masks::Client::MANAGE_KEY
  end

  setup { Masks.installation.modify!(email: { enabled: true }) }

  test "login via email is disabled when email.enabled = false" do
    Masks.installation.modify!(email: { enabled: false })

    authorize
    attempt(identifier: "masks@example.com", password: "password")

    refute_authorized
  end

  test "login via nickname when nickname.enabled = false" do
    Masks.installation.modify!(nickname: { enabled: false })

    authorize
    attempt(identifier: "manager", password: "password")

    refute_authorized
  end

  test "login via email is only allowed for 'login' group" do
    email = "masks@example.com"
    authorize
    attempt(identifier: email, password: "password")
    assert_authorized

    seeder
      .manager
      .emails
      .find_by!(address: email, group: "login")
      .update_attribute("group", "test")
    authorize
    attempt(identifier: email, password: "password")

    refute_authorized
  end
end
