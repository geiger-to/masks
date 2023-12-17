# frozen_string_literal: true

require "test_helper"

module Masks
  # [GET|POST|PATCH|DELETE] /masks/backup-codes
  #
  # view and configure backup codes, which are available and
  # created automatically after setting some other form of
  # secondary authentication.
  class BackupCodesTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

    test "enabling one-time codes creates backup codes" do
      signup_as "admin" do
        add_one_time_code

        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        assert actor.factor2?
        assert actor.should_save_backup_codes?
        refute actor.saved_backup_codes?
        assert actor.backup_codes
      end
    end

    test "POST enables backup codes with the enable param" do
      signup_as "admin" do
        add_one_time_code

        save_backup_codes

        assert_equal 302, status
        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        assert actor.factor2?
        refute actor.should_save_backup_codes?
        assert actor.saved_backup_codes?
        assert actor.backup_codes
      end
    end

    test "POST with the enable param requires a password" do
      signup_as "admin" do
        add_one_time_code

        save_backup_codes password: "invalid"

        assert_equal 302, status
        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        assert actor.should_save_backup_codes?
        refute actor.saved_backup_codes?
      end
    end

    test "POST with the reset param resets the codes before enabling" do
      signup_as "admin" do
        add_one_time_code

        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        codes = actor.backup_codes

        assert_equal 12, codes.keys.length

        reset_backup_codes
        actor.reload

        assert_equal 12, actor.backup_codes.keys.length
        refute_equal codes.keys.sort, actor.backup_codes.keys.sort
        assert actor.factor2?
        assert actor.should_save_backup_codes?
        refute actor.saved_backup_codes?
      end
    end

    test "POST with the reset param resets the codes after enabling" do
      signup_as "admin" do
        add_one_time_code

        actor = Masks::Rails::Actor.find_by(nickname: "admin")
        codes = actor.backup_codes

        save_backup_codes

        assert_equal 12, codes.keys.length

        reset_backup_codes

        actor.reload

        assert_equal 12, actor.backup_codes.keys.length
        refute_equal codes.keys.sort, actor.backup_codes.keys.sort
        assert actor.factor2?
        assert actor.should_save_backup_codes?
        refute actor.saved_backup_codes?
      end
    end

    test "POST /session accepts a backup code after saving" do
      signup_as "admin" do
        add_one_time_code
        save_backup_codes
      end

      login_as "admin" do
        refute_logged_in
      end

      actor = Masks::Rails::Actor.find_by!(nickname: "admin")
      code = actor.backup_codes.keys.first

      login_as "admin", backup_code: code do
        assert_logged_in
      end

      refute actor.reload.backup_codes[code]
    end

    test "POST /session does not require re-entering a username/password" do
      signup_as "admin" do
        add_one_time_code
        save_backup_codes
      end

      login_as "admin" do
        refute_logged_in

        actor = Masks::Rails::Actor.find_by!(nickname: "admin")
        code = actor.backup_codes.keys.first

        post "/session", params: { session: { backup_code: code } }

        assert_logged_in
      end
    end

    def dummy_app?
      true
    end
  end
end
