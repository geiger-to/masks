class MasksTestCase < ActionDispatch::IntegrationTest
  setup do
    DatabaseCleaner.clean

    Masks.reset!
    Masks.seed!

    @tester = nil
    @client = nil
    @manage_client = nil
    @manager = nil
    @user_agent = nil

    seeds.actor!(
      nickname: "tester",
      email: "test@example.com",
      password: "password",
    )
  end

  def seeds
    Masks.seeds
  end

  def make_actor
    Masks.signup("nick#{SecureRandom.alphanumeric(10)}").tap { |a| a.save! }
  end

  def make_client(name: nil)
    Masks::Client.create!(
      name: name || "client#{SecureRandom.alphanumeric(10)}",
    )
  end

  def make_device
    Masks::Device.create!(
      public_id: SecureRandom.uuid,
      ip_address: "127.0.0.1",
      user_agent:,
    )
  end

  def make_entry
    Masks::Entry.create!(
      client: make_client,
      device: make_device,
      actor: make_actor,
    )
  end

  def make_session
    Masks::Session.create!(data: "", session_id: SecureRandom.uuid)
  end

  def make_auth_code
    entry = make_entry

    Masks::AuthorizationCode.create!(
      client: entry.client,
      actor: entry.actor,
      device: entry.device,
      entry:,
    )
  end

  def make_access_token
    entry = make_entry

    Masks::AccessToken.create!(
      client: entry.client,
      actor: entry.actor,
      device: entry.device,
      entry:,
    )
  end

  def make_id_token
    entry = make_entry

    Masks::IdToken.create!(
      client: entry.client,
      actor: entry.actor,
      device: entry.device,
      nonce: SecureRandom.uuid,
      entry:,
    )
  end

  def manage_client
    @manage_client ||= Masks::Client.manage
  end

  def manager
    @manager ||= Masks::Actor.find_by!(nickname: "manager")
  end

  def tester
    @tester ||= Masks::Actor.find_by!(nickname: "tester")
  end

  def user_agent
    @user_agent ||= [
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
      "AppleWebKit/605.1.15 (KHTML, like Gecko)",
      "Version/17.4 Safari/605.1.15",
    ].join(" ")
  end

  def iphone_ua!
    @user_agent = [
      "Mozilla/5.0 (iPhone14,3; U; CPU iPhone OS 15_0 like Mac OS X)",
      "AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/19A346",
      "Safari/602.1",
    ].join(" ")
  end

  def firefox_ua!
    @user_agent = [
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0)",
      "Gecko/20100101 Firefox/15.0.1",
    ].join(" ")
  end
end
