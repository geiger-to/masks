source "https://rubygems.org"

gem "rails", "~> 8.0.1"
gem "puma", ">= 5.0"
gem "pg", "~> 1.1"
gem "sqlite3", "~> 2.4"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem "solid_queue", "~> 1.1"
gem "solid_cache", "~> 1.0"
gem "solid_cable", "~> 3.0"
gem "mission_control-jobs", "~> 1.0"
gem "propshaft", "~> 1.1"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "prettier_print", "~> 1.2"
  gem "syntax_tree", "~> 6.2"
  gem "syntax_tree-haml", "~> 4.0"
  gem "syntax_tree-rbs", "~> 1.0"
  gem "database_cleaner-active_record", "~> 2.2"
  gem "simplecov", "~> 0.22.0"
  gem "simplecov-cobertura", "~> 2.1"
  gem "dotenv"
  gem "vcr", "~> 6.3"
  gem "webmock", "~> 3.24"
end

group :development do
  gem "letter_opener", "~> 1.10"
  gem "web-console"
  gem "byebug", "~> 11.1"
  gem "graphiql-rails"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "database_cleaner", "~> 2.1"
end

group :development, :doc do
  gem "jekyll", "~> 4.3"
  gem "yard", "~> 0.9.36"
end

gem "recursive-open-struct", "~> 2.0", group: %i[default jekyll_plugins]

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-postcss"
  gem "jekyll-toc", "~> 0.18.0"
end

# Frontend
gem "vite_rails", "~> 3.0"
gem "graphql", "~> 2.4"
gem "apollo_upload_server", "~> 2.1"
gem "rack-cors", "~> 2.0"

# ActiveRecord
gem "ulid", "~> 1.4"
gem "activerecord-session_store", "~> 2.1"
gem "validates_host", "~> 1.3"
gem "validate_url", "~> 1.0"
gem "valid_email", "~> 0.2.1"

# Email
gem "premailer-rails", "~> 1.12"

# Auth libs
gem "chronic_duration", "~> 0.10.6"
gem "device_detector", "~> 1.1"
gem "openid_connect", "~> 2.3"
gem "bcrypt", "~> 3.1"
gem "fuzzyurl", "~> 0.9.0"

# Phones and OTP
gem "rotp", "~> 6.3"
gem "rqrcode", "~> 2.2"
gem "phonelib", "~> 0.10.3"
gem "webauthn", "~> 3.1"
gem "fido_metadata",
    git: "https://github.com/bdewater/fido_metadata",
    branch: "main"

# Client libraries
gem "twilio-ruby", "~> 7.4"
gem "image_processing", "~> 1.13"
gem "csv", "~> 3.3"
gem "geocoder", "~> 1.8"

# Monitoring
gem "stackprof"
gem "sentry-ruby"
gem "sentry-rails"
gem "newrelic_rpm", require: false

gem "yabeda", "~> 0.13.1"
gem "yabeda-rails", "~> 0.9.0"
gem "prometheus-client-mmap", "~> 1.1"
gem "yabeda-prometheus-mmap", "~> 0.4.0"
gem "yabeda-activerecord", "~> 0.1.1"
gem "yabeda-graphql", "~> 0.2.3"
gem "yabeda-puma-plugin", "~> 0.7.1"
gem "yabeda-http_requests", "~> 0.2.1"
gem "yabeda-activejob", "~> 0.6.0"

gem "foreman", "~> 0.88.1"
