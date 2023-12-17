# frozen_string_literal: true

module Masks
  # @visibility private
  module Manage
    class BaseController < ApplicationController
      # require_mask type: :manage

      layout "masks/manage"
    end
  end
end
