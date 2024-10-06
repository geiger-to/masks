ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require_relative "masks_test_case"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    teardown { DatabaseCleaner.clean }
  end
end
