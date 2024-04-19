# frozen_string_literal: true

require "test_helper"

module Masks
  # [GET|POST] /session
  #
  # Test cases for creating new account (signup).
  #
  # This includes validations, creation via various types, and more.
  class SignupTest < ActionDispatch::IntegrationTest
    include Masks::TestHelper

  end
end
