require "test_helper"

module Masks
  class InlineTest < ActiveSupport::TestCase
    include Masks::TestHelper

    test "Masks.inline does not yield if session.passed? = false" do
      refute Masks.revealed?(mask_path("inline"), name: "test-param")
    end

    test "Masks.inline fails if credentials are invalid" do
      params = { nickname: "test" } # too short
      session =
        Masks.reveal(mask_path("inline"), name: "test-param", params: params) do |_|
          raise "this should never happen"
        end

      refute session.passed?
      assert_includes session.errors.full_messages,
                      "Nickname is too short (minimum is 5 characters)"
    end

    test "Masks.inline yields if session.passed? = true" do
      params = { nickname: "testing" }
      run = false
      session =
        Masks.reveal(mask_path("inline"), name: "test-param", params: params) { |_| run = true }

      assert session.passed?
      assert run
    end
  end
end
