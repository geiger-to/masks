# frozen_string_literal: true

require "test_helper"

class MasksTest < ActiveSupport::TestCase
  include Masks::TestHelper

  test "it has a version number" do
    assert Masks::VERSION
  end

  test "it loads configuration from Dir.pwd if it exists" do
    Dir.stubs(:pwd).returns(__dir__)

    assert_equal "custom", Masks.config[:name]
  end

  test "it loads configuration from custom directories" do
    Masks.config_path = __dir__

    assert_equal "custom", Masks.config[:name]
  end

  test "it loads configuration from a directory specified by an ENV var" do
    ENV["MASKS_DIR"] = __dir__

    assert_equal "custom", Masks.config[:name]
  ensure
    ENV["MASKS_DIR"] = nil
  end

  protected

  def masks_json
    nil
  end
end
