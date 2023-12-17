require "test_helper"

module Masks
  # [DELETE] /session
  #
  # logout, by deleting a session. this deletes the current actor from
  # the session before it could automatically expire because of time
  # or other factors.
  class LogoutTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "DELETE requires an existing session" do
      delete "/session"
      assert_equal status, 302
    end

    test "DELETE deletes existing sessions" do
      signup_as "admin"
      delete "/session"

      refute_logged_in
    end

    test "DELETE deletes allows login after logout" do
      signup_as "admin"
      assert_logged_in
      delete "/session"
      refute_logged_in
      login_as "admin"
      assert_logged_in
    end

    test "DELETE /session allows logout during login (e.g. 2fa)" do
      signup_as "admin" do
        add_one_time_code
        delete "/session"
      end

      login_as "admin" do
        refute_logged_in

        delete "/session"

        actor = Masks::Rails::Actor.find_by!(nickname: "admin")
        code = actor.totp.now

        post "/session", params: { session: { one_time_code: code } }

        refute_logged_in
      end
    end
  end
end
