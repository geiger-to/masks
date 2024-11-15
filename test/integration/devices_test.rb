require "test_helper"

class DevicesTest < MasksTestCase
  include AuthHelper

  test "invalid user agents are blocked" do
    @user_agent = "invalid"

    authorize

    assert_prompt "device"
    assert_warning "invalid-device"
    assert_artifacts
  end

  test "missing clients don't create devices" do
    authorize(path: "/authorize/foobar.json")

    assert_prompt "missing-client"
    assert_artifacts
  end

  test "devices can be blocked" do
    authorize

    Masks::Device.first.block!

    authorize

    assert_prompt "device"
    assert_warning "blocked-device"
    assert_artifacts devices: 1
  end
end
