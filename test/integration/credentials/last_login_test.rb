require "test_helper"

module Credentials
  # Masks::Credentials::LastLogin
  #
  # doesn't perform any verification, but updates last_login timestamp.
  class LastLoginTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "POST /masks/sessions sets last_login_at on signup" do
      signup_as "test"

      actor = Masks::Rails::Actor.find_by(nickname: "@test")

      assert actor.last_login_at
    end

    test "POST /masks/sessions changes last_login_at on login" do
      signup_as "test"

      actor = Masks::Rails::Actor.find_by(nickname: "@test")
      time = actor.last_login_at

      assert actor.last_login_at

      travel 1.minute

      login_as "test"

      refute_equal time, actor.reload.last_login_at
    end

    test "POST /masks/sessions does not change last_login_at on browse" do
      signup_as "test"

      actor = Masks::Rails::Actor.find_by(nickname: "@test")
      time = actor.last_login_at

      assert actor.last_login_at

      travel 1.minute

      get "/private"

      assert_equal time, actor.reload.last_login_at
    end

    private

    def dummy_app?
      true
    end
  end
end
