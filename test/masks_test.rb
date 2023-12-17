require "test_helper"

class MasksTest < ActiveSupport::TestCase
  include Masks::TestHelper

  test "it has a version number" do
    assert Masks::VERSION
  end

  test "it loads configuration from 'masks.json'" do
    assert Masks.config
  end

  test "it loads configuration from Dir.pwd if it exists" do
    Dir.stubs(:pwd).returns(mask_path("pwd").to_s)

    assert_equal "pwd", Masks.config[:name]
  end

  test "it loads configuration from custom directories" do
    Masks.config_path = __dir__

    assert_equal "custom", Masks.config[:name]
  end

  test "it loads configuration from a directory specified by an ENV var" do
    ENV["MASKS_DIR"] = mask_path("env").to_s

    assert_equal "env", Masks.config[:name]
  ensure
    ENV["MASKS_DIR"] = nil
  end

  test ".with_config allows overriding config with a path+block" do
    name = nil

    Masks.with_config(mask_path("inline")) { name = Masks.config[:name] }

    assert_equal "inline", name
    refute Masks.config[:name]
  end

  test ".with_config allows overriding config with an object + block" do
    name = nil
    data = { name: SecureRandom.hex }

    Masks.with_config(data) { name = Masks.config[:name] }

    assert_equal data[:name], name
    refute Masks.config[:name]
  end
end
