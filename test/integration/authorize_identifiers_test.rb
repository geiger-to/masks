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

  test "login via email prefers LOGIN_VERIFIED_GROUP" do
    email = "masks@example.com"
    seeder.manager.emails.for_login.find_by!(address: email).verify!
    seeder.seed_actor(nickname: "test1", password: "password", email:) # unverified by default

    authorize
    attempt(identifier: email, password: "password")
    assert_authorized
    assert_actor "manager"
  end

  test "login via email is allowed for LOGIN_UNVERIFIED_GROUP" do
    email = "masks@example.com"
    authorize
    attempt(identifier: email, password: "password")
    assert_authorized

    seeder
      .manager
      .emails
      .find_by!(address: email, group: Masks::Email::LOGIN_UNVERIFIED_GROUP)
      .update_attribute("group", "test")
    authorize
    attempt(identifier: email, password: "password")

    refute_authorized
    assert_actor "manager"
  end
end
