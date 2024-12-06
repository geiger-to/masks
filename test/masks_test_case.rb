class MasksTestCase < ActionDispatch::IntegrationTest
  setup do
    DatabaseCleaner.clean

    Masks.reset!
    Masks.seed!

    seeds.actor!(
      nickname: "tester",
      email: "test@example.com",
      password: "password",
    )
  end

  def seeds
    Masks.seeds
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
end
