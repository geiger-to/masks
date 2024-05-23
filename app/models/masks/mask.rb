# frozen_string_literal: true

module Masks
  class Mask < ApplicationRecord
    attribute :session
    attribute :tenant
    attribute :profile
  end
end
