# frozen_string_literal: true
require "test_helper"

module Masks
  module OpenID
    class ClientTest < ActiveSupport::TestCase
      test "#validate a name is required" do
        client = Masks::Rails::OpenID::Client.new
        refute client.valid?
        client.name = "test"
        assert client.valid?
      end

      test "#validate a key is generated based on the name" do
        client = Masks::Rails::OpenID::Client.new
        client.name = "This is a test!"
        assert client.valid?
        assert_equal "this-is-a-test", client.key
      end

      test "#validate key generation appends a suffix to avoid uniqueness failures" do
        client = Masks::Rails::OpenID::Client.new
        client.name = "This is a test!"
        client.save!

        client2 = Masks::Rails::OpenID::Client.new
        client2.name = "This is a test!"
        client2.save!

        client3 = Masks::Rails::OpenID::Client.new
        client3.name = "This is a test!"
        client3.save!

        assert_equal "this-is-a-test-2", client2.key
        assert_equal "this-is-a-test-3", client3.key
      end
    end
  end
end
