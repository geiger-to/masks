class MasksTestCase < ActionDispatch::IntegrationTest
  def seeder
    @seeder ||= Masks::Seeder.new
  end

  setup do
    Masks.env.url = "http://example.com"
    Masks.reset!
    Masks.install!
    seeder.seed_env!
  end
end
