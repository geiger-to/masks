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

  test "devices are recorded after login" do
    log_in "manager"

    assert_artifacts devices: 1
  end

  test "sessions are reset if the cookie expires (or is absent)" do
    log_in "manager"

    cookie = cookies[Masks::Prompts::Device::COOKIE]
    assert_login
    assert_logged_in :get, "/manage"

    cookies[Masks::Prompts::Device::COOKIE] = nil
    authorize

    assert_prompt "identify"
    refute_logged_in :get, "/manage"

    cookies[Masks::Prompts::Device::COOKIE] = cookie

    authorize

    assert_prompt "identify"
    refute_logged_in :get, "/manage"

    assert_artifacts devices: 2
  end

  test "sessions are reset if user agent changes" do
    iphone_ua!

    log_in "manager"

    assert_login
    assert_logged_in :get, "/manage"

    firefox_ua!

    authorize

    assert_prompt "device"
    assert_equal "User agent changed. You must log in again.",
                 auth_result.dig("extras", "device_errors").first
    refute_logged_in :get, "/manage"

    authorize
    assert_prompt "identify"
  end

  test "sessions are reset if ip address changes" do
    log_in "manager"

    assert_login
    assert_logged_in :get, "/manage"

    self.remote_addr = "10.0.0.2"

    authorize

    assert_prompt "device"
    assert_equal "IP address changed. You must log in again.",
                 auth_result.dig("extras", "device_errors").first
    refute_logged_in :get, "/manage"

    authorize
    assert_prompt "identify"

    log_in "manager"
    assert_login
    assert_logged_in :get, "/manage"
  end

  test "sessions are reset if version changes" do
    log_in "manager"

    device = Masks::Device.first

    assert_login
    assert_logged_in :get, "/manage"

    device.version = "12345"
    device.save!

    authorize

    assert_prompt "device"
    assert_equal "This device has expired.",
                 auth_result.dig("extras", "device_errors").first
    refute_logged_in :get, "/manage"

    authorize
    assert_prompt "identify"

    log_in "manager"
    assert_login
    assert_logged_in :get, "/manage"
  end

  test "attempts expire if version change" do
    log_in "manager"

    device = Masks::Device.first

    assert_login
    assert_logged_in :get, "/manage"

    device.version = "12345"
    device.save!

    attempt

    assert_prompt "missing-client"
    refute_logged_in :get, "/manage"
  end
end
