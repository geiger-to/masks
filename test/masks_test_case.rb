class MasksTestCase < ActionDispatch::IntegrationTest
  def seeder
    @seeder ||= Masks::Seeder.new
  end

  delegate :manager, :tester, to: :seeder

  setup do
    Masks.env.url = "http://www.example.com"
    Masks.reset!
    Masks.install!
    seeder.seed_env!
  end
end
