ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "database_cleaner/active_record"
require "rails/test_help"
require "byebug"
require "vcr"

Dir[Rails.root.join("test", "helpers", "**", "*.rb")].each do |file|
  require file
end

require_relative "masks_test_case"
require_relative "client_test_case"
require_relative "graphql_test_case"

DatabaseCleaner.strategy = :deletion

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock

  # assume authorization headers are sensitive
  config.filter_sensitive_data("<AUTHORIZATION>") do |interaction|
    next unless interaction.request.headers["Authorization"]
    interaction.request.headers["Authorization"][0]
  end

  # a custom request matcher that looks at all headers *except* Authorization,
  # because we're filtering out the content of that header, which means
  # we can't use that header for matching
  headers_without_authorization =
    lambda do |request_1, request_2|
      request_1.headers.except("Authorization") ==
        request_2.headers.except("Authorization")
    end

  config.default_cassette_options = { match_requests_on: %i[method uri] }
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    teardown do
      DatabaseCleaner.clean
      Mail::TestMailer.deliveries.clear
    end
  end
end
