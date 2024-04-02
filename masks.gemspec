# frozen_string_literal: true

require_relative "lib/masks/version"

Gem::Specification.new do |spec|
  spec.name = "masks"
  spec.version = Masks::VERSION
  spec.authors = ["geiger-to"]
  spec.email = ["git@geiger.to"]
  spec.homepage = "https://masks.geiger.to"
  spec.summary = "mask ruby applications with auth"
  spec.description =
    "masks is a ruby library and rails engine that adds simple, extensible auth to most applications. DO NOT USE"
  spec.license = "MIT"
  spec.required_ruby_version = "~> 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/geiger-to/masks"
  spec.metadata["changelog_uri"] = "https://masks.geiger.to/changelog"

  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      Dir[
        "{app,config,db,lib}/**/*",
        "MIT-LICENSE",
        "Rakefile",
        "README.md",
        "masks.json"
      ]
    end

  spec.add_dependency "alba"
  spec.add_dependency "bcrypt", "~> 3.1"
  spec.add_dependency "cssbundling-rails", "~> 1.3"
  spec.add_dependency "device_detector"
  spec.add_dependency "fuzzyurl", "~> 0.9.0"
  spec.add_dependency "jsbundling-rails", "~> 1.2"
  spec.add_dependency "openid_connect", "~> 2.3"
  spec.add_dependency "pagy"
  spec.add_dependency "phonelib"
  spec.add_dependency "premailer-rails", "~> 1"
  spec.add_dependency "rails", ">= 7.1.2"
  spec.add_dependency "recursive-open-struct"
  spec.add_dependency "rotp"
  spec.add_dependency "rqrcode"
  spec.add_dependency "sprockets-rails"
  spec.add_dependency "stimulus-rails", "~> 1.3"
  spec.add_dependency "turbo-rails", ">= 1.5", "< 3.0"
  spec.add_dependency "valid_email", "~> 0.2"
  spec.metadata["rubygems_mfa_required"] = "true"
end
