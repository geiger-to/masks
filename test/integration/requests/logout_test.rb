require "test_helper"

module Masks
  # [DELETE] /masks/session
  #
  # logout, by deleting a session. this deletes the current actor from
  # the session before it could automatically expire because of time
  # or other factors.
  class LogoutTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "DELETE requires an existing session" do
      delete "/masks/sessions"

      refute session["session_id"]
    end

    test "DELETE deletes existing sessions" do
      signup_as "test" do
        delete "/masks/session"
        assert_equal 302, status

        refute_logged_in
      end
    end

    test "DELETE deletes allows login after logout" do
      signup_as "test" do
        delete "/masks/session"

        login_as "test" do
          assert_logged_in
        end
      end

      refute_logged_in

      login_as "test" do
        assert_logged_in
      end
    end

    test "DELETE deletes allows logout during login (e.g. 2fa)" do
      signup_as "test" do
        add_one_time_code
      end

      login_as "test" do
        refute_logged_in

        delete "/masks/session"

        actor = Masks::Rails::Actor.find_by!(nickname: "@test")
        code = actor.totp.now

        post "/masks/session", params: { session: { one_time_code: code } }

        refute_logged_in
      end
    end

    private

    def dummy_app?
      true
    end
  end
end
