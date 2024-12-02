class MasksTestCase < ActionDispatch::IntegrationTest
  attr_reader :seeder

  delegate :manager, :tester, to: :seeder

  setup do
    Masks.env.url = "http://www.example.com"
    Masks.installation&.destroy!
    Masks.reset!
    Masks.install!

    @seeder = Masks::Seeder.new(Masks.installation)
    @seeder.seed_env!
  end
end
