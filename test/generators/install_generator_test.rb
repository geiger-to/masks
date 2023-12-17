# frozen_string_literal: true

require "test_helper"
require "generators/masks/install/install_generator"

module Masks
  class InstallGeneratorTest < ::Rails::Generators::TestCase
    tests Masks::InstallGenerator
    destination ::Rails.root.join("tmp/generators")
    setup :prepare_destination

    test "generator runs without errors" do
      assert_nothing_raised { run_generator }
    end
  end
end
