require "test_helper"

module Masks
  # [GET|POST] /session
  #
  # sessions, actors, and devices are versioned. if their versions
  # change while in use, sessions should be invalidated.
  class VersionsTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "changing Masks.configuration.version expires all sessions" do
      signup_as "admin"
      assert_logged_in

      new_device do
        login_as "admin2"
        assert_logged_in

        Masks.configuration.version = "v2"

        refute_logged_in

        login_as "admin2"
        assert_logged_in
      end

      refute_logged_in

      login_as "admin"
      assert_logged_in
    end

    test "changing the actor's version expires all of their sessions" do
      signup_as "admin"
      assert_logged_in

      new_device do
        login_as "admin"
        assert_logged_in

        Masks::Rails::Actor.first.update_attribute(:version, "v2")

        refute_logged_in
        login_as "admin"
        assert_logged_in
      end

      refute_logged_in

      login_as "admin"
      assert_logged_in
    end

    test "DELETE /device/:key ends all sessions for the device" do
      device1 = nil
      device2 = nil

      signup_as "admin" do
        device1 = Masks::Rails::Actor.find_by!(nickname: "admin").devices.first

        assert device1
        assert_logged_in
      end

      new_device do
        login_as "admin"

        device2 = Masks::Rails::Actor.find_by!(nickname: "admin").devices.first

        assert_equal device1, device2
        assert_logged_in

        post "/device/#{device2.key}", params: { reset: true }

        refute_logged_in

        login_as "admin"
        assert_logged_in
      end
    end
  end
end
