# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in masks.gemspec.
gemspec

gem "puma"
gem "sqlite3"
gem "yard", "~> 0.9.36"

# Start debugger with binding.b [https://github.com/ruby/debug]
gem "byebug"
gem "debug", ">= 1.0.0"
gem "mocha"

gem "htmlbeautifier", "~> 1.4"
gem "letter_opener", "~> 1.8"
gem "lucide-rails",
    "~> 0.2.0",
    github: "zest-ui/lucide-rails",
    branch: "update-to-294"

gem "guard", "~> 2.18"
gem "guard-shell", "~> 0.7.2"
gem "jekyll", "~> 4.3"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-postcss"
  gem "jekyll-toc", "~> 0.18.0"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", platforms: %i[mingw x64_mingw mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", platforms: [:jruby]

gem "prettier_print", "~> 1.2"
gem "syntax_tree", "~> 6.2"
gem "syntax_tree-haml", "~> 4.0"
gem "syntax_tree-rbs", "~> 1.0"

gem "brakeman", "~> 6.1"

gem "rubocop", "~> 1.62"

gem "bundler-audit", "~> 0.9.1"
