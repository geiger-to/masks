# frozen_string_literal: true

require "test_helper"

module Masks
  # [DELETE] /device/:key
  #
  # delete devices and expire sessions
  class DevicesTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "DELETE /device/:key ends all sessions for the device" do
      device1 = nil
      device2 = nil

      signup_as "admin" do
        device1 = Masks::Rails::Actor.find_by!(nickname: "admin").devices.first

        assert device1
        assert_logged_in

        post "/device/#{device1.key}", params: { reset: true }

        refute_logged_in

        post "/session",
             params: {
               session: {
                 nickname: "admin",
                 password: "password"
               }
             }

        assert_logged_in
      end

      new_device do
        login_as "admin" do
          device2 =
            Masks::Rails::Actor.find_by!(nickname: "admin").devices.first

          assert_equal device1, device2
          assert_logged_in

          post "/device/#{device2.key}", params: { reset: true }

          refute_logged_in
        end
      end
    end
  end
end
